module Cards
  class Manager
    property deck : Deck
    getter seats : Array(Seat)
    getter seat_players : Array(SeatPlayer)
    getter players : Array(CardPlayer)
    getter dealer : Dealer
    getter decks
    getter? shuffling

    @deck_stack : CardStack
    @discard_stack : CardStack
    @cards : Array(Card)

    DEFAULT_NUMBER_OF_DECKS = 6
    SHUFFLE_LIMIT_PERCENT = 0.3_f32

    def initialize(@deck, @decks = DEFAULT_NUMBER_OF_DECKS, @seats = [] of Seat, seat_players = [] of SeatPlayer, @dealer = Dealer.new)
      @players = [] of CardPlayer
      @seat_players = [] of SeatPlayer

      seats.each do |seat|
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
        x: Main.screen_width - Card.width - CardSpot.margin,
        y: CardSpot.margin,
        cards: decks.times.flat_map { @deck.cards.clone }.to_a
      )
      @shuffle_stack = CardStack.new(
        x: Main.screen_width - Card.width * 2 - CardSpot.margin * 2,
        y: CardSpot.margin
      )
      @discard_stack = CardStack.new(
        x: CardSpot.margin,
        y: CardSpot.margin
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
      # seat player seats
      @seats.each(&.draw(screen_x, screen_y))

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
          all_busted_or_blackjack = seat_players.all? { |p| p.bust? || p.blackjack? }
          @dealer.play(all_busted_or_blackjack)
        else
          player.play
        end
      end

      if player.hitting?
        player.hitting = false
        player.deal(@deck_stack.take)
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
      if player.done?
        if player.is_a?(SeatPlayer)
          if seat_player = player.as(SeatPlayer)
            if seat_player.settled_bet?
              seat_player.clear_table(@discard_stack) unless seat_player.cleared_table?
            else
              seat_player.settle_bet(@dealer)
            end
          end
        else
          player.clear_table(@discard_stack)
        end

        if player.cleared_table?
          if players.all? { |p| p.done? && p.cleared_table? }
            # check for shuffling
            if shuffling?
              shuffle
              return
            elsif shuffle?
              shuffle_setup
              return
            end

            new_hand
          else
            @done_index += 1
            next_turn
          end
        end
      else
        player.done(@dealer)
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
      player.deal(@deck_stack.take) unless player.dealt?

      next_turn
    end
  end
end
