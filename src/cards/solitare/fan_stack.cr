module Cards
  module Solitare
    class FanStack < CardStack
      CARD_HEIGHT_PEAK = 30

      def update_cards_position
        @cards.each_with_index do |card, index|
          card.position.x = x
          card.position.y = y + index * (Card.height_depth + CARD_HEIGHT_PEAK)
        end
      end

      def add_position
        Game::Vector.new(
          x: x,
          y: y + @cards.size * (Card.height_depth + CARD_HEIGHT_PEAK)
        )
      end
    end
  end
end
