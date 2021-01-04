module Cards
  class CardSpot
    property position : Game::Vector

    delegate :x, :y, to: position

    WIDTH = Card::WIDTH
    HEIGHT = Card::HEIGHT

    MARGIN = 10
    BORDER = 2

    def initialize(@position = Game::Vector.new)
    end

    def initialize(x, y)
      @position = Game::Vector.new(x: x, y: y)
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
