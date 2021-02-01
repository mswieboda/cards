module Cards
  module Solitare
    class Stock < CardStack
      getter? hovered
      getter? pressed

      def initialize(x = 0, y = 0, @cards = [] of Card)
        super

        @hovered = false
        @pressed = false
      end

      def update(frame_time)
        super

        @hovered = @cards.any? && Game::Mouse.in?(
          x: x,
          y: y - height_depth,
          width: width,
          height: height
        )
        @pressed = hovered? && Game::Mouse::Left.pressed?
      end

      def draw(screen_x = 0, screen_y = 0)
        super

        if Main::DEBUG && hovered?
          Game::RoundedRectangle.new(
            x: screen_x + x,
            y: screen_y + y - height_depth,
            width: width,
            height: height,
            roundness: 0.15_f32,
            thickness: 3,
            filled: false,
            color: pressed? ? Game::Color::Purple : Game::Color::Yellow
          ).draw
        end
      end
    end
  end
end
