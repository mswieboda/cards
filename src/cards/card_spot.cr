module Cards
  class CardSpot
    property x : Int32 | Float32
    property y : Int32 | Float32

    WIDTH = Card::WIDTH
    HEIGHT = Card::HEIGHT

    MARGIN = 10
    BORDER = 2

    def initialize(@x = 0, @y = 0)
    end

    def self.margin
      MARGIN
    end

    def self.width
      WIDTH
    end

    def self.height
      HEIGHT
    end

    def width
      self.class.width
    end

    def height
      self.class.height
    end

    def draw(screen_x = 0, screen_y = 0)
      return unless Main::DEBUG

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
