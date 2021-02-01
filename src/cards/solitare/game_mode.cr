module Cards
  module Solitare
    class GameMode < Cards::GameMode
      getter? dealt

      MARGIN = 25
      FAN_STACKS = 7
      DEAL_CARDS = (FAN_STACKS + 1).times.to_a.sum

      @stock : Stock
      @stacks : Array(Stack)
      @cards : Array(Card)
      @stack_drag : Stack?
      @stack_drag_delta : Game::Vector
      @stack_drag_to_stack : CardStack
      @stack_drag_released : Bool

      def initialize
        super

        @deal_index = 0
        @deal_row_index = 0
        @dealt = false

        deck = StandardDeck.new(jokers: false)
        @stock = Stock.new(
          x: MARGIN,
          y: MARGIN,
          cards: deck.cards.clone
        )

        @waste = Waste.new(
          x: @stock.x + Card.width + MARGIN * 2,
          y: MARGIN
        )

        @stacks = FAN_STACKS.times.to_a.map do |index|
          Stack.new(
            x: @stock.x + index * (MARGIN * 2 + Card.width),
            y: @stock.y + Card.height + MARGIN * 2
          )
        end

        @cards = [] of Card
        @stack_drag = nil
        @stack_drag_delta = Game::Vector.zero
        @stack_drag_to_stack = @waste
        @stack_drag_released = false
      end

      def update(frame_time)
        @cards.each(&.update(frame_time))

        if !dealt?
          deal
          return
        end

        @stock.update(frame_time)
        @waste.update(frame_time)

        @cards.select(&.moved?).each do |card|
          @cards.delete(card)
          @waste.add(card)
          card.flip if card.flipped?
        end

        if @stock.pressed?
          card = @stock.take
          card.move(@waste.add_position)
          @cards << card
        elsif @waste.pressed?
          card = @waste.take
          @stack_drag_delta = @waste.pressed_delta
          @stack_drag = Stack.new(x: card.x, y: card.y, cards: [card])
        end

        if stack = @stack_drag
          stack.update(frame_time)

          if @stack_drag_released
            if stack.moved?
              @stack_drag_to_stack.add(stack)
              @stack_drag = nil
              @stack_drag_delta = Game::Vector.zero
              @stack_drag_released = false
            end
          else
            stack.x = Game::Mouse.x - @stack_drag_delta.x
            stack.y = Game::Mouse.y - @stack_drag_delta.y

            unless Game::Mouse::Left.down?
              @stack_drag_to_stack = @waste

              if to_stack = @stacks.find(&.mouse_in?)
                @stack_drag_to_stack = to_stack
              end

              stack.move(@stack_drag_to_stack.add_position)
              @stack_drag_released = true
            end
          end
        end
      end

      def draw
        super
        @stock.draw
        @waste.draw
        @stacks.each(&.draw)
        @cards.each(&.draw)

        if stack = @stack_drag
          stack.draw
        end
      end

      def deal_stack_index(prev_row = false)
        spaces = (@deal_row_index + 1).times.to_a.sum
        (@deal_index + spaces) % @stacks.size
      end

      def deal
        @cards.select(&.moved?).each do |card|
          stack_index = deal_stack_index
          stack = @stacks[stack_index]

          stack.add(card)
          @cards.delete(card)

          card.flip if stack.size >= stack_index + 1

          @deal_row_index += 1 if stack_index >= @stacks.size - 1
          @deal_index += 1
        end

        return if @cards.any?(&.moving?)

        if @deal_index >= DEAL_CARDS
          @dealt = true
          return
        end

        card = @stock.take
        card.move(@stacks[deal_stack_index].add_position)
        @cards << card
      end
    end
  end
end
