require "./chip_tray"

module Cards
  class BetTray < ChipTray
    getter? hovered
    getter? selected

    @sprite_highlight : Game::Sprite

    def initialize(x = 0, y = 0, amount = Amount::Five)
      super

      @hovered = false
      @selected = false
      @sprite_highlight = Game::Sprite.get(:chip_highlight)
    end

    def self.amounts : Array(BetTray)
      Chip::Amount.values.map { |amount| BetTray.new(amount: amount) }
    end

    def to_chip : Chip
      chip = Chip.new(amount: @amount)
      chip.position = position.clone
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
          x: screen_x + x - (@sprite_highlight.width - width) / 2_f32,
          y: screen_y + y - (@sprite_highlight.height - height) / 2_f32,
          tint: Game::Color::Yellow
        )
      end
    end
  end
end
