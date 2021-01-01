module Cards
  abstract class Deck
    property back : CardBack
    property front : CardFront
    property cards : Array(Card)

    def initialize(@back = CardBacks::Bordered.new, @front = CardFronts::Standard.new, @cards = [] of Card)
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
