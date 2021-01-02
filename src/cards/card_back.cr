module Cards
  abstract class CardBack
    getter color : Game::Color
    getter alt_color : Game::Color

    BORDER = 3

    def initialize(@color = Game::Color::Red, @alt_color = Game::Color::Black)
    end

    def draw(screen_x, screen_y, width, height)
      draw_back_border(screen_x, screen_y, width, height)
      draw_design(screen_x + BORDER, screen_y + BORDER, width - BORDER * 2, height - BORDER * 2)
    end

    def draw_back_border(screen_x, screen_y, width, height)
      Game::RoundedRectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        roundness: 0.15_f32,
        color: Game::Color::Ivory
      ).draw
    end
  end
end
