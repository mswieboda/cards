module Cards
  module Blackjack
    class Manager
      property deck : Deck
      getter seat_players : Array(SeatPlayer)
      getter players : Array(CardPlayer)
      getter dealer : Dealer
      getter decks
      getter? shuffling

      @seats : Array(Seat)
      @deck_stack : CardStack
      @discard_stack : CardStack
      @cards : Array(Card)

      DEFAULT_NUMBER_OF_DECKS = 6
      SHUFFLE_LIMIT_PERCENT = 0.3_f32

      def initialize(@deck, @decks = DEFAULT_NUMBER_OF_DECKS, @seats = [] of Seat, seat_players = [] of SeatPlayer, @dealer = Dealer.new)
        @players = [] of CardPlayer
        @seat_players = [] of SeatPlayer

        @seats.each do |seat|
          if seat.player?
            if player = seat_players.find { |p| p == seat.player }
              @seat_players << player
            end
            next
          end

          if player = seat_players.find(&.unseated?)
            player.seat = seat
            @seat_players << player
          end
        end

        @players += @seat_players
        @players << @dealer

        @turn_index = 0
        @done_index = 0

        @deck_stack = CardStack.new(
          x: Main.screen_width - Card.width - Card.margin,
          y: Card.margin,
          cards: decks.times.flat_map { @deck.cards.clone }.to_a
        )
        @shuffle_stack = CardStack.new(
          x: Main.screen_width - Card.width * 2 - Card.margin * 2,
          y: Card.margin
        )
        @discard_stack = CardStack.new(
          x: Card.margin,
          y: Card.margin
        )

        @cards = [] of Card
        @shuffling = false

        @deck_stack.shuffle!
      end

      def update(frame_time)
        players.each(&.update(frame_time))

        # for shuffling
        @cards.each(&.update(frame_time))

        manage_turn
      end

      def draw(screen_x = 0, screen_y = 0)
        # for shuffling
        @cards.each(&.draw(screen_x, screen_y))

        # card stacks
        @deck_stack.draw(screen_x, screen_y)
        @discard_stack.draw(screen_x, screen_y)
        @shuffle_stack.draw(screen_x, screen_y)

        # players
        dealer.draw(screen_x, screen_y)
        seat_players.each(&.draw(screen_x, screen_y))
      end

      def turn_player
        players[@turn_index]
      end

      def next_turn
        turn_player.next_turn

        @turn_index += 1
        @turn_index = 0 if @turn_index >= players.size
      end

      def manage_turn
        return if players.any?(&.delay?)
        return if players.any?(&.dealing?)

        remove_leaving_players

        if bets_ready?
          player = turn_player

          if play_hand?
            play(player)
          elsif played?
            next_turn if first_turn_and_dealer?(player)
            done(player)
          else
            deal(player)
          end
        end
      end

      def remove_leaving_players
        seat_players.select(&.leave_table?).each do |player|
          # TODO: message that player is leaving table
          @players.delete(player)
        end
      end

      def bets_ready?
        seat_players.none?(&.placing_bet?) && seat_players.all?(&.confirmed_bet?)
      end

      def play_hand?
        players.all?(&.dealt?) && !players.all?(&.played?)
      end

      def play(player : CardPlayer)
        unless player.played? || player.playing?
          if player == @dealer
            all_busted_or_blackjack = seat_players.flat_map(&.hands).all? { |h| h.bust? || h.blackjack? }
            @dealer.play(all_busted_or_blackjack)
          else
            player.play
          end
        end

        if player.hitting?
          player.hitting = false
          player.deal(@deck_stack)
          player.hand_check
        end

        next_turn if player.played?
      end

      def played?
        players.all?(&.played?)
      end

      def first_turn_and_dealer?(player : CardPlayer)
        @done_index == 0 && player == @dealer
      end

      def done(player : CardPlayer)
        if !player.done?
          player.done(@dealer)
        else
          settle_bet_clear_hands(player)

          if player.cleared_table?
            if players.all? { |p| p.done? && p.cleared_table? }
              if shuffling?
                shuffle
              elsif shuffle?
                shuffle_setup
              else
                new_hand
              end
            else
              @done_index += 1
              next_turn
            end
          end
        end
      end

      def settle_bet_clear_hands(player : CardPlayer)
        if player.is_a?(SeatPlayer)
          if seat_player = player.as(SeatPlayer)
            if seat_player.settling_bets?
              seat_player.settle_bet(@dealer)
            else
              seat_player.clear_table(@discard_stack) unless seat_player.cleared_table?
            end
          end
        else
          player.clear_table(@discard_stack)
        end
      end

      def take_sample(from : CardStack, to : CardStack, frames = 16)
        return if from.empty?

        if card = from.take_sample
          card.move(to.add_card_position, frames)
          @cards << card
        end
      end

      def shuffle?
        !shuffling? && @deck_stack.size / (decks * @deck.size) <= SHUFFLE_LIMIT_PERCENT
      end

      def shuffle_setup
        @cards.select(&.moved?).each do |card|
          @cards.delete(card)
          @shuffle_stack.add(card)
        end

        if @deck_stack.empty? && @discard_stack.empty? && @cards.empty? && @shuffle_stack.any?
          @shuffling = true
          return
        end

        take_sample(from: @deck_stack, to: @shuffle_stack)
        take_sample(from: @discard_stack, to: @shuffle_stack)
      end

      def shuffle
        @cards.select(&.moved?).each do |card|
          @cards.delete(card)
          @deck_stack.add(card)
        end

        if @shuffle_stack.empty? && @cards.empty? && @deck_stack.any?
          @shuffling = false
          return
        end

        take_sample(from: @shuffle_stack, to: @deck_stack, frames: 2)
      end

      def new_hand
        @turn_index = 0
        @done_index = 0

        players.each do |player|
          player.new_hand
        end
      end

      def deal(player : CardPlayer)
        player.deal(@deck_stack) unless player.dealt?

        next_turn unless player.splitting?
      end
    end
  end
end
