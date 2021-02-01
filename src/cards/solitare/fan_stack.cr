module Cards
  module Solitare
    class FanStack < CardStack
      PEEK = 25

      def update_cards_position
        @cards.each_with_index do |card, index|
          card.position.x = x
          card.position.y = y + index * (Card.height_depth + PEEK)
        end
      end

      def add_position
        Game::Vector.new(
          x: x,
          y: y + @cards.size * (Card.height_depth + PEEK)
        )
      end

      def mouse_in?
        if any?
          cards.last.mouse_in?
        else
          Game::Mouse.in?(
            x: x,
            y: y,
            width: Card.width,
            height: Card.height
          )
        end
      end
    end
  end
end
