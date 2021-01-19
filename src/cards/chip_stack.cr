module Cards
  class ChipStack
    getter chips : Array(Chip)
    getter position : Game::Vector

    delegate :x, :y, to: position
    delegate :size, :empty?, to: chips

    def initialize(x = 0, y = 0, @chips = [] of Chip)
      @position = Game::Vector.new(
        x: x,
        y: y
      )

      init_chip_frames
      update_chips_position
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
        if @chips.size > 1
          # ensure chip frame isn't same as last
          if last = @chips[index - 1]
            while chip.frame == last.frame
              chip.frame = rand(chip.frames)
            end
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

    def take : Chip | Nil
      @chips.pop
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

    def draw(screen_x = 0, screen_y = 0)
      @chips.each(&.draw(screen_x, screen_y))
    end
  end
end
