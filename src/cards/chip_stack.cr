module Cards
  class ChipStack
    getter chips : Array(Chip)
    getter position : Game::Vector
    getter? selectable
    getter? hovered
    getter? selected

    delegate :x, :y, to: position
    delegate :size, :empty?, to: chips

    @sprite_highlight : Game::Sprite

    def initialize(x = 0, y = 0, @chips = [] of Chip, @selectable = false)
      @position = Game::Vector.new(
        x: x,
        y: y
      )

      @hovered = false
      @selected = false
      @sprite_highlight = Game::Sprite.get(:chip_highlight)

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

    def self.amounts : Array(ChipStack)
      Chip::Amount.values.map { |amount| ChipStack.new }
    end

    def self.width
      Chip.width
    end

    def width
      self.class.width
    end

    def top_y
      y - height
    end

    def height
      @chips.size * Chip.height_depth
    end

    def init_chip_frames
      @chips.each_with_index do |chip, index|
        update_last_chip_frame(chip: chip, last_index: index - 1)
      end
    end

    def update_last_chip_frame(chip = @chips[-1], last_index = -2)
      return if @chips.size < 2 || last_index == 0 || last_index + @chips.size == 0

      while chip.frame == @chips[last_index].frame
        chip.frame = rand(chip.frames)
      end
    end

    def add(chip : Chip)
      @chips << chip
      update_last_chip_frame
      update_chips_position
    end

    def take : Chip
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

    def selected_chip
      if selected?
        if chips.any?
          if chip = chips[-1]
            chip.copy
          end
        end
      end
    end

    def update(frame_time)
      if selectable?
        if @chips.any?
          @hovered = Game::Mouse.in?(
            x: x,
            y: y - height,
            width: width,
            height: height + Chip.height
          )
        else
          @hovered = Game::Mouse.in?(
            x: x,
            y: y - Chip.height_depth,
            width: width,
            height: Chip.height_depth + Chip.height
          )
        end

        @selected = hovered? && Game::Mouse::Left.pressed?
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      @chips.each(&.draw(screen_x, screen_y))

      draw_x = screen_x - (@sprite_highlight.width - width) / 2_f32
      draw_y = screen_y - (@sprite_highlight.height - Chip.height) / 2_f32

      if hovered?
        if @chips.any?
          if chip = chips[-1]
            draw_x += chip.x
            draw_y += chip.y
          else
            draw_x += x
            draw_y += y
          end
        else
          draw_x += x
          draw_y += y
        end

        @sprite_highlight.draw(
          x: draw_x,
          y: draw_y,
          tint: Game::Color::Yellow
        )
      end
    end
  end
end
