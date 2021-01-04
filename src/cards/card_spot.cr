module Cards
  class CardSpot
    property x : Int32 | Float32
    property y : Int32 | Float32

    WIDTH = Card::WIDTH
    HEIGHT = Card::HEIGHT

    BORDER = 2

    def initialize(@x = 0, @y = 0)
    end

    # methods for width/height in case of changing to instance vars later
    def self.width
      WIDTH
    end

    def self.height
      HEIGHT
    end

    def width
      WIDTH
    end

    def height
      HEIGHT
    end

    def draw(screen_x = 0, screen_y = 0)
      Game::RoundedRectangle.new(
        x: screen_x + x,
        y: screen_y + y,
        width: width,
        height: height,
        roundness: 0.15_f32,
        thickness: BORDER,
        color: Game::Color::Black,
        filled: false
      ).draw
    end
  end
end
