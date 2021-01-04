module Cards
  abstract class CardPlayer
    property card_spots : Array(CardSpot)
    property cards : Array(Card)

    @dealing_card : Nil | Card

    def initialize(@card_spots = [] of CardSpot, @cards = [] of Card)
    end

    def update(_frame_time)
      if dealing?
        if dealing_card = @dealing_card
          if dealing_card.moved?
            @cards << dealing_card
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
      cards.size == 2
    end

    def deal(card : Card)
      card.flip if card.flipped?
      card_spot = card_spots[cards.size]
      card.move_to(card_spot)
      @dealing_card = card
    end
  end
end
