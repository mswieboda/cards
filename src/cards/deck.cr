module Cards
  abstract class Deck
    property cards : Array(Card)

    def initialize(@cards = [] of Card)
    end

    def draw(screen_x, screen_y)
      # draw top card
      @cards[0].draw(screen_x, screen_y)

      # TODO: draw shadow bottom/right to show depth?
    end

    def shuffle!
      @cards.shuffle!
    end
  end
end
