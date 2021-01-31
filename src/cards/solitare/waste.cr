module Cards
  module Solitare
    class Waste < CardStack
      PEEK = 15

      def update_cards_position
        @cards.each_with_index do |card, index|
          card.position.x = x + index * PEEK
          card.position.y = y
        end
      end

      def add_position
        Game::Vector.new(
          x: x + @cards.size * PEEK,
          y: y
        )
      end
    end
  end
end
