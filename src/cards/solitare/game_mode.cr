module Cards
  module Solitare
    class GameMode < Cards::GameMode
      MARGIN = 25

      @row_stacks : Array(RowStack)

      def initialize
        super

        deck = StandardDeck.new(jokers: false)
        cards = deck.cards.clone
        @stack = CardStack.new(
          x: MARGIN,
          y: MARGIN,
          cards: cards
        )

        @row_stacks = 7.times.to_a.map do |index|
          cards = deck.cards.clone
          cards = cards[0..(index + 1)]

          RowStack.new(
            x: @stack.x + index * (MARGIN * 2 + Card.width),
            y: @stack.y + Card.height + MARGIN * 2,
            cards: cards
          )
        end
      end

      def update(frame_time)
      end

      def draw
        super
        @stack.draw
        @row_stacks.each(&.draw)
      end
    end
  end
end
