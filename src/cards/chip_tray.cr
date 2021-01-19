module Cards
  class ChipTray
    getter amount : Chip::Amount
    getter position : Game::Vector

    delegate :x, :x=, :y, :y=, to: position

    @sprite : Game::Sprite
    @sprite_accent : Game::Sprite

    def initialize(x = 0, y = 0, @amount = Chip::Amount::Five)
      @position = Game::Vector.new(
        x: x,
        y: y
      )
      @sprite = Game::Sprite.get(:chip_color)
      @sprite_accent = Game::Sprite.get(:chip_accent)
    end

    def draw(screen_x = 0, screen_y = 0)
      @sprite.draw(x: screen_x + x, y: screen_y + y, tint: @amount.color)
      @sprite_accent.draw(x: screen_x + x, y: screen_y + y, tint: @amount.color_accent)
    end
  end
end
