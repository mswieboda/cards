require "./chip"

module Cards
  class BetChip < Chip
    getter? hovered
    getter? selected

    @sprite_highlight : Game::Sprite

    def initialize(amount = Amount::Five)
      super

      @hovered = false
      @selected = false
      @sprite_highlight = Game::Sprite.get(:chip_highlight)
    end

    def self.amounts : Array(BetChip)
      Chip::Amount.values.map { |amount| BetChip.new(amount: amount) }
    end

    def to_chip : Chip
      chip = Chip.new(amount: @amount)
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
