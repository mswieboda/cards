module Cards
  abstract class CardBack
    getter color : Game::Color
    getter alt_color : Game::Color

    def initialize(@color = Game::Color::Red, @alt_color = Game::Color::Black)
    end

    def draw(screen_x, screen_y, width, height)
    end
  end
end
