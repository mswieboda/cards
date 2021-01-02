module Cards
  abstract class Deck
    property x : Int32
    property y : Int32
    property back : CardBack
    property front : CardFront
    property cards : Array(Card)

    def initialize(@back = CardBacks::Bordered.new, @front = CardFronts::Standard.new, @cards = [] of Card)
      @x = @y = 0
    end

    def update(frame_time)
      @cards.each(&.update(frame_time))
    end

    def draw(screen_x = 0, screen_y = 0)
      # draw top card
      # TODO: draw shadow bottom/right to show depth?
      # @cards[0].draw(screen_x + x, screen_y + y)

      @cards.each(&.draw(screen_x, screen_y))
    end

    def shuffle!
      @cards.shuffle!
    end
  end
end
