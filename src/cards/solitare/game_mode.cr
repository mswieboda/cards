module Cards
  module Solitare
    class GameMode < Cards::GameMode
      getter? dealt
      getter? clearing_waste

      MARGIN = 25
      FAN_STACKS = 7
      DEAL_CARDS = (FAN_STACKS + 1).times.to_a.sum

      @stock : Stock
      @waste : Waste
      @stacks : Array(Stack)
      @foundations : Array(Foundation)
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
        @clearing_waste = false

        deck = StandardDeck.new(jokers: false)
        @stock = Stock.new(
          x: MARGIN,
          y: MARGIN,
          cards: deck.cards.clone.shuffle!
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

        @foundations = Suit.values.map_with_index do |suit, index|
          Foundation.new(
            suit: suit,
            x: Main.screen_width - MARGIN - Card.width - index * (MARGIN * 2 + Card.width),
            y: MARGIN
          )
        end

        @cards = [] of Card
        @stack_drag = nil
        @stack_drag_delta = Game::Vector.zero
        @stack_drag_to_stack = @waste
        @stack_drag_released = false
      end

      def update(frame_time)
        super

        @cards.each(&.update(frame_time))

        return if !dealt? && deal
        return if clear_waste(frame_time)
        return if move_cards_to_waste
        return if flip_up_stack_top_card
        return if drag_stack(frame_time)
      end

      def draw
        super
        @stock.draw
        @waste.draw
        @foundations.each(&.draw)
        @stacks.each(&.draw)
        @cards.each(&.draw)

        if stack = @stack_drag
          stack.draw
        end
      end

      def move_cards_to_waste
        @cards.select(&.moved?).each do |card|
          @cards.delete(card)
          @waste.add(card)
          card.flip if card.flipped?
        end

        if card = @stock.take_pressed
          # move from stock to waste
          card.move(@waste.add_position)
          @cards << card
          return true
        end
      end

      def flip_up_stack_top_card
        if stack = @stacks.find(&.flip_up_top_card?)
          stack.flip_up_top_card
          return true
        end
      end

      def drag_stack(frame_time)
        # check for drag stack from waste or stacks
        ([@waste] + @stacks + @foundations).each do |stack|
          if stack_drag = stack.take_pressed_stack
            @stack_drag = stack_drag
            @stack_drag_delta = Game::Mouse.position - stack_drag.position
            @stack_drag_to_stack = stack
            return true
          end
        end

        # if we're dragging a stack
        if stack = @stack_drag
          stack.update(frame_time)

          if @stack_drag_released
            if stack.moved?
              # add to target stack
              @stack_drag_to_stack.add(stack)
              @stack_drag = nil
              @stack_drag_delta = Game::Vector.zero
              @stack_drag_released = false
            end
          else
            # move stack with mouse
            stack.x = Game::Mouse.x - @stack_drag_delta.x
            stack.y = Game::Mouse.y - @stack_drag_delta.y

            # release stack
            unless Game::Mouse::Left.down?
              if to_stack = (@stacks + @foundations).find(&.add?(stack))
                @stack_drag_to_stack = to_stack
              end

              stack.move(@stack_drag_to_stack.add_position)
              @stack_drag_released = true
            end
          end

          # check for move to foundation
          # TODO: switch to left mouse double click, or left & right click
          if Game::Mouse::Left.down? && Game::Key::Space.pressed?
            if foundation = @foundations.find(&.add?(stack: stack, auto: true))
              @stack_drag_to_stack = foundation
              @stack_drag_released = true
              stack.move(@stack_drag_to_stack.add_position)
              return true
            end
          end
        end
      end

      def clear_waste(frame_time)
        if @stock.empty? && @stock.pressed?
          @clearing_waste = true

          @waste.cards.each_with_index do |card, index|
            card.move(@stock.add_position(index))
          end

          return true
        end

        return unless clearing_waste?

        @waste.update(frame_time)

        if @waste.cards.all?(&.moved?)
          @waste.flip!

          @stock.add(@waste)
          @stock.update_cards_position

          @clearing_waste = false
        end

        true
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

        return true if @cards.any?(&.moving?)

        if @deal_index >= DEAL_CARDS
          @dealt = true
          return true
        end

        card = @stock.take
        card.move(@stacks[deal_stack_index].add_position)
        @cards << card
      end
    end
  end
end
