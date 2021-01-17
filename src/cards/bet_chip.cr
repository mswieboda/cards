require "./chip"

module Cards
  class BetChip < Chip
    getter? hovered
    getter? selected

    @sprite_highlight : Game::Sprite

    def initialize(value = Value::Five)
      super

      @hovered = false
      @selected = false
      @sprite_highlight = Game::Sprite.get(:chip_highlight)
    end

    def self.values : Array(BetChip)
      Chip::Value.values.map { |value| BetChip.new(value: value) }
    end

    def to_chip : Chip
      chip = Chip.new(value: @value)
      chip.position = position.copy
      chip
    end

    def update(frame_time)
      @hovered = Game::Mouse.in?(x: x, y: y, width: width, height: height)
      @selected = hovered? && Game::Mouse::Left.pressed?
    end

    def draw(screen_x = 0, screen_y = 0)
      super

      if hovered?
        @sprite_highlight.draw(
          x: screen_x + x - (@sprite_highlight.width - @sprite.width) / 2_f32,
          y: screen_y + y - (@sprite_highlight.height - @sprite.height) / 2_f32,
          tint: Game::Color::Yellow
        )
      end
    end
  end
end
