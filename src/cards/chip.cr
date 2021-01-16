module Cards
  class Chip
    property position : Game::Vector
    property color : Game::Color

    delegate :x, :y, to: position

    @sprite : Game::Sprite
    @move_to : Nil | Game::Vector
    @move_delta : Game::Vector

    WIDTH = 32
    HEIGHT = 16
    HEIGHT_DEPTH = 3

    MOVEMENT_FRAMES = 15

    def initialize(@color = Game::Color::Red)
      @sprite = Game::Sprite.get(:chip_color)
      @sprite_accent = Game::Sprite.get(:chip_accent)
      @position = Game::Vector.new
      @move_to = nil
      @move_delta = Game::Vector.new
    end

    def self.width
      WIDTH
    end

    def self.height
      HEIGHT
    end

    def self.height_depth
      HEIGHT_DEPTH
    end

    # methods for width/height in case of changing to instance vars later
    def width
      self.class.width
    end

    def height
      self.class.height
    end

    def height_depth
      self.class.height_depth
    end

    def moving?
      !!@move_to
    end

    def moved?
      !moving?
    end

    def move(move_to : Game::Vector)
      @move_to = move_to.copy
      @move_delta = move_to.subtract(position) / MOVEMENT_FRAMES
    end

    def update(frame_time)
      if moving?
        if move_to = @move_to
          @position.x += @move_delta.x
          @position.y += @move_delta.y

          # if we've reached or gone past `move_to`, snap to it
          if (@move_delta.x.sign >= 0 && @move_delta.x + @position.x >= move_to.x) ||
            (@move_delta.x.sign < 0 && @move_delta.x + @position.x <= move_to.x)
            @position.x = move_to.x
          end

          if (@move_delta.y.sign >= 0 && @move_delta.y + @position.y >= move_to.y) ||
            (@move_delta.y.sign < 0 && @move_delta.y + @position.y <= move_to.y)
            @position.y = move_to.y
          end

          # if we're there, clear `move_to`
          @move_to = nil if @position.x == move_to.x && @position.y == move_to.y
        end
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      @sprite.draw(x: screen_x + x, y: screen_y + y, tint: color)
      @sprite_accent.draw(x: screen_x + x, y: screen_y + y)
    end
  end
end
