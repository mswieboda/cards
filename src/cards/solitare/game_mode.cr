module Cards
  module Solitare
    class GameMode < Cards::GameMode
      getter? dealt

      MARGIN = 25
      FAN_STACKS = 7
      DEAL_CARDS = (FAN_STACKS + 1).times.to_a.sum

      @fan_stacks : Array(FanStack)
      @cards : Array(Card)

      def initialize
        super

        @deal_index = 0
        @deal_row_index = 0
        @dealt = false

        deck = StandardDeck.new(jokers: false)
        @stack = CardStack.new(
          x: MARGIN,
          y: MARGIN,
          cards: deck.cards.clone
        )

        @fan_stacks = FAN_STACKS.times.to_a.map do |index|
          FanStack.new(
            x: @stack.x + index * (MARGIN * 2 + Card.width),
            y: @stack.y + Card.height + MARGIN * 2
          )
        end

        @cards = [] of Card

      end

      def update(frame_time)
        @cards.each(&.update(frame_time))

        if !dealt?
          deal
          return
        end
      end

      def draw
        super
        @stack.draw
        @fan_stacks.each(&.draw)
        @cards.each(&.draw)
      end

      def deal_fan_stack_index(prev_row = false)
        spaces = (@deal_row_index + 1).times.to_a.sum
        (@deal_index + spaces) % @fan_stacks.size
      end

      def deal
        @cards.select(&.moved?).each do |card|
          fan_stack_index = deal_fan_stack_index

          @fan_stacks[fan_stack_index].add(card)
          @cards.delete(card)

          @deal_row_index += 1 if fan_stack_index >= @fan_stacks.size - 1
          @deal_index += 1
        end

        return if @cards.any?(&.moving?)

        if @deal_index >= DEAL_CARDS
          @dealt = true
          return
        end

        card = @stack.take
        card.move(@fan_stacks[deal_fan_stack_index].add_position)
        @cards << card
      end
    end
  end
end
