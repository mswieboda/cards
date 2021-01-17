module Cards
  class Manager
    property deck : Deck
    getter seats : Array(Seat)
    getter seat_players : Array(SeatPlayer)
    getter players : Array(CardPlayer)
    getter dealer : Dealer

    @deck_stack : CardStack
    @discard_stack : CardStack

    def initialize(@deck, @seats = [] of Seat, seat_players = [] of SeatPlayer, @dealer = Dealer.new)
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
        cards: @deck.cards.dup
      )
      @discard_stack = CardStack.new(
        x: CardSpot.margin,
        y: CardSpot.margin
      )

      @deck_stack.shuffle!
    end

    def update(frame_time)
      players.each(&.update(frame_time))

      manage_turn
    end

    def draw(screen_x = 0, screen_y = 0)
      @seats.each(&.draw(screen_x, screen_y))
      seat_players.each(&.draw(screen_x, screen_y))
      dealer.draw(screen_x, screen_y)
      @deck_stack.draw(screen_x, screen_y)
      @discard_stack.draw(screen_x, screen_y)
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
        elsif done?
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
      seat_players.none?(&.placing_bet?) && seat_players.all?(&.placed_bet?)
    end

    def play_hand?
      players.all?(&.dealt?) && !players.all?(&.played?)
    end

    def play(player : CardPlayer)
      if !player.playing?
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

    def done?
      players.all?(&.played?)
    end

    def first_turn_and_dealer?(player : CardPlayer)
      @done_index == 0 && player == @dealer
    end

    def done(player : CardPlayer)
      if player.done?
        # clear cards
        player.cards.select(&.moved?).each do |card|
          if card = player.cards.delete(card)
            @discard_stack.add(card)
          end
        end

        if player.cards.empty?
          @done_index += 1
          next_turn

          new_hand if players.all? { |p| p.done? && p.cards.empty? }
        end
      else
        player.done(@dealer)
        player.cards.each do |card|
          card.move(@discard_stack.position)
        end
      end
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
