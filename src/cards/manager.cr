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

      @deck_stack.shuffle!
    end

    def update(frame_time)
      players.each(&.update(frame_time))

      manage_turn
    end

    def draw(screen_x = 0, screen_y = 0)
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
      return if players.any?(&.dealing?)

      if seat_players.all?(&.placed_bet?) && players.none?(&.delay?)
        player = turn_player

        if play_hand?
          play(player)
        elsif done?
          done(player)
        elsif deal?
          deal(player)
        end
      end
    end

    def play_hand?
      players.all?(&.dealt?) && !players.all?(&.played?) && players.none?(&.delay?)
    end

    def play(player : CardPlayer)
      player.play if !player.playing?

      if player.hitting?
        player.hitting = false
        player.deal(@deck_stack.take)
        player.hand_check
      end

      next_turn if player.played?
    end

    def done?
      players.all?(&.played?) && players.none?(&.delay?)
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
          next_turn

          new_hand if players.all? { |p| p.done? && p.cards.empty? && !p.delay? }
        end
      else
        # start moving cards
        player.done

        player.cards.each do |card|
          card.move(@discard_stack.position)
        end
      end
    end

    def new_hand
      @turn_index = 0

      players.each do |player|
        player.new_hand
      end
    end

    def deal?
      players.none?(&.delay?)
    end

    def deal(player : CardPlayer)
      player.deal(@deck_stack.take) unless player.dealt?

      next_turn
    end
  end
end
