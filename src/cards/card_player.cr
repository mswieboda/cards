module Cards
  abstract class CardPlayer
    property card_spots : Array(CardSpot)
    property cards : Array(Card)
    getter? playing
    getter? played
    getter? done

    @dealing_card : Nil | Card

    DONE_DELAY = 0.69

    def initialize(@card_spots = [] of CardSpot, @cards = [] of Card)
      @playing = false
      @played = false
      @done = false
    end

    def update(frame_time)
      cards.each(&.update(frame_time))

      if dealing?
        if dealing_card = @dealing_card
          if dealing_card.moved?
            @dealing_card = nil
          end
        end
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      card_spots.each(&.draw(screen_x, screen_y))
      cards.each(&.draw(screen_x, screen_y))
    end

    def dealing?
      !!@dealing_card
    end

    def dealt?
      !dealing? && cards.size == 2
    end

    def deal(card : Card)
      card.flip if card.flipped?
      card_spot = card_spots[cards.size]
      card.move_to = card_spot.position
      @cards << card
      @dealing_card = card
    end

    def play
      @playing = true
    end

    def stand
      @playing = false
      @played = true
    end

    def done
      sleep DONE_DELAY
      @done = true
    end

    def new_hand
      @playing = false
      @played = false
      @done = false
    end
  end
end
