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
    end
  end
end
