module Cards
  module Solitare
    class Stock < CardStack
      def draw(screen_x = 0, screen_y = 0)
        super

        if empty?
          Game::RoundedRectangle.new(
            x: screen_x + x,
            y: screen_y + y,
            width: width,
            height: height,
            roundness: 0.15_f32,
            color: Game::Color::Black.alpha(33_u8)
          ).draw
        end
      end
    end
  end
end
