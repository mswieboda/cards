module Cards
  class Manager
    property deck : Deck
    getter seat_players : Array(SeatPlayer)
    getter players : Array(CardPlayer)
    getter dealer : Dealer

    @deck_stack : Stack
    @discard_stack : Stack

    def initialize(@deck, @seat_players = [] of SeatPlayer, @dealer = Dealer.new)
      @players = [] of CardPlayer
      @players += seat_players
      @players << @dealer

      @turn_index = 0

      @deck_stack = Stack.new(
        x: Main.screen_width - Card.width - CardSpot.margin,
        y: CardSpot.margin,
        cards: @deck.cards.dup
      )
      @discard_stack = Stack.new(
        x: CardSpot.margin,
        y: CardSpot.margin
      )
    end

    def update(frame_time)
      players.each(&.update(frame_time))

      return if players.any?(&.dealing?)

      if seat_players.all?(&.placed_bet?)
        if players.all?(&.dealt?)
          # TODO: play hands
        else
          deal
        end
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      seat_players.each(&.draw(screen_x, screen_y))
      dealer.draw(screen_x, screen_y)
      @deck_stack.draw(screen_x, screen_y)
      @discard_stack.draw(screen_x, screen_y)
    end

    def next_turn
      @turn_index += 1
      @turn_index = 0 if @turn_index >= players.size
    end

    def turn_player
      players[@turn_index]
    end

    def deal
      puts ">>> deal!"

      player = turn_player

      player.deal(@deck_stack.take) unless player.dealt?

      next_turn
    end
  end
end
