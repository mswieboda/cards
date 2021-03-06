module Cards
  abstract class CardBack
    getter color : Game::Color
    getter alt_color : Game::Color

    BORDER = 3

    def initialize(@color = Game::Color::Red, @alt_color = Game::Color::Black)
    end

    def draw(screen_x, screen_y, width, height)
      draw_design(screen_x + BORDER, screen_y + BORDER, width - BORDER * 2, height - BORDER * 2)
      draw_border(screen_x, screen_y, width, height)
    end

    def draw_border(screen_x, screen_y, width, height)
      Game::RoundedRectangle.new(
        x: screen_x + BORDER,
        y: screen_y + BORDER,
        width: width - BORDER * 2,
        height: height - BORDER * 2,
        roundness: 0.15_f32,
        thickness: BORDER,
        color: Game::Color::Ivory,
        filled: false
      ).draw
    end
  end
end
