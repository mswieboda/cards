module Cards
  module Solitare
    class Stack < CardStack
      MARGIN_X = 0
      MARGIN_Y = 25

      def self.margin_x
        MARGIN_X
      end

      def self.margin_y
        MARGIN_Y
      end

      def margin_x
        self.class.margin_x
      end

      def margin_y
        self.class.margin_y
      end

      def width
        super + @cards.size * margin_x
      end

      def height_depth
        0
      end

      def height
        super + @cards.size * margin_y
      end

      def update_cards_position
        @cards.each_with_index do |card, index|
          card.position.x = margin_x.zero? ? x : x + index * margin_x
          card.position.y = margin_y.zero? ? y : y + index * (self.class.height_depth + margin_y)
        end
      end

      def add_position
        Game::Vector.new(
          x: x,
          y: y + @cards.size * (self.class.height_depth + margin_y)
        )
      end

      def take_pressed_stack
        return unless pressed?
        return if empty?

        index = @cards.reverse.index(&.mouse_in?)

        return unless index

        index = @cards.size - 1 - index
        card = @cards[index]

        self.class.new(x: card.x, y: card.y, cards: @cards.delete_at(index..-1))
      end

      def drop?(stack : Stack)
        return false if stack.empty? || !mouse_in?
        return true if empty?

        top = @cards.last
        bottom = stack.cards.first

        top.rank.value == bottom.rank.value + 1 && !top.suit.pair?(bottom.suit)
      end
    end
  end
end
