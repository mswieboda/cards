module Cards
  class ChipStack
    getter chips : Array(Chip)
    getter position : Game::Vector

    delegate :x, :y, to: position
    delegate :size, to: chips

    @move_to : Nil | Game::Vector
    @move_delta : Game::Vector

    MOVEMENT_FRAMES = 15

    def initialize(x = 0, y = 0, @chips = [] of Chip)
      @position = Game::Vector.new(
        x: x,
        y: y
      )
      @move_to = nil
      @move_delta = Game::Vector.new

      init_chip_frames
      update_chips_position
    end

    def update(frame_time)
      chips.each(&.update(frame_time))
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

    def x=(value : Int32 | Float32)
      @position.x = value
      update_chips_position
    end

    def y=(value : Int32 | Float32)
      @position.y = value
      update_chips_position
    end

    def init_chip_frames
      @chips.each_with_index do |chip, index|
        # ensure chip frame isn't same as last (TODO: or next chip)
        if last = @chips[index - 1]
          while chip.frame == last.frame
            chip.frame = rand(chip.frames)
          end
        end
      end
    end

    def add(chip : Chip)
      last = @chips[-1] unless @chips.empty?

      @chips << chip

      if last
        while chip.frame == last.frame
          chip.frame = rand(chip.frames)
        end
      end

      update_chips_position
    end

    def add_chip_position
      Game::Vector.new(
        x: x,
        y: y - @chips.size * Chip.height_depth
      )
    end

    def update_chips_position
      @chips.each_with_index do |chip, index|
        chip.position.x = x
        chip.position.y = y - index * Chip.height_depth
      end
    end

    def chip_value
      @chips.map(&.value).sum
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

          update_chips_position
        end
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      @chips.each(&.draw(screen_x, screen_y))
    end
  end
end
