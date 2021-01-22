module Cards
  class Chip
    property position : Game::Vector
    getter amount : Amount

    delegate :x, :y, to: position
    delegate :frame, :frames, to: @sprite
    delegate :value, to: @amount

    @sprite : Game::Sprite
    @sprite_accent : Game::Sprite
    @move_to : Nil | Game::Vector
    @move_delta : Game::Vector

    WIDTH = 32
    HEIGHT = 16
    HEIGHT_DEPTH = 3

    MOVEMENT_FRAMES = 20

    enum Amount : UInt8
      One = 1
      Five = 5
      Twenty = 20
      Fifty = 50
      Hundred = 100

      def color
        case self
        when One
          Game::Color::White
        when Five
          Game::Color::Red
        when Twenty
          Game::Color::Green
        when Fifty
          Game::Color::Blue
        when Hundred
          Game::Color.new(color: 33)
        else
          raise "Chip::Amount#color error amount not found: #{self}"
        end
      end

      def color_accent
        case self
        when One
          Game::Color.new(color: 33)
        else
          Game::Color::White
        end
      end

      def to_chip
        Chip.new(amount: self)
      end
    end

    def initialize(@amount = Amount::Five)
      @sprite = Game::Sprite.get(:chip_color)
      @sprite_accent = Game::Sprite.get(:chip_accent)

      frame = rand(@sprite.frames)
      @sprite.frame = frame
      @sprite_accent.frame = frame

      @position = Game::Vector.new
      @move_to = nil
      @move_delta = Game::Vector.new
    end

    def self.amounts : Array(Chip)
      Chip::Amount.values.map { |amount| amount.to_chip }
    end

    def self.largest(total : Int32 | Float32) : Chip | Nil
      return if total <= 0

      if amount = Chip::Amount.values.reverse.find { |amount| amount.value <= total }
        amount.to_chip
      end
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
      @move_to = move_to.clone
      @move_delta = move_to.subtract(position) / MOVEMENT_FRAMES
    end

    def frame=(frame : Int32)
      @sprite.frame = frame
      @sprite_accent.frame = frame
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
      @sprite.draw(x: screen_x + x, y: screen_y + y, tint: @amount.color)
      @sprite_accent.draw(x: screen_x + x, y: screen_y + y, tint: @amount.color_accent)
    end
  end
end
