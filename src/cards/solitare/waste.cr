require "./stack"

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

      def add_position(index = @cards.size - 1)
        Game::Vector.new(
          x: x + (index + 1) * margin_x,
          y: y
        )
      end

      def mouse_in?
        any? && cards.last.mouse_in?
      end

      def take_pressed_stack : Stack?
        return unless pressed?
        return if empty?

        card = take

        Stack.new(x: card.x, y: card.y, cards: [card])
      end
    end
  end
end
