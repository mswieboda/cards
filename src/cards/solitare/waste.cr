module Cards
  module Solitare
    class Waste < Stack
      MARGIN_X = 15
      MARGIN_Y = 0

      def self.margin_x
        MARGIN_X
      end

      def self.margin_y
        MARGIN_Y
      end

      def add_position
        Game::Vector.new(
          x: x + @cards.size * margin_x,
          y: y
        )
      end

      def mouse_in?
        any? && cards.last.mouse_in?
      end

      def take_pressed_stack
        return unless pressed?
        return if empty?

        card = take

        self.class.new(x: card.x, y: card.y, cards: [card])
      end
    end
  end
end
