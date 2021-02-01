module Cards
  module Solitare
    class GameMode < Cards::GameMode
      getter? dealt

      MARGIN = 25
      FAN_STACKS = 7
      DEAL_CARDS = (FAN_STACKS + 1).times.to_a.sum

      @stock : Stock
      @fan_stacks : Array(FanStack)
      @cards : Array(Card)
      @card_drag : Card?
      @card_drag_delta : Game::Vector
      @card_drag_to_stack : CardStack
      @card_drag_released : Bool

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

        @fan_stacks = FAN_STACKS.times.to_a.map do |index|
          FanStack.new(
            x: @stock.x + index * (MARGIN * 2 + Card.width),
            y: @stock.y + Card.height + MARGIN * 2
          )
        end

        @cards = [] of Card
        @card_drag = nil
        @card_drag_delta = Game::Vector.zero
        @card_drag_to_stack = @waste
        @card_drag_released = false
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
          @card_drag_delta = @waste.pressed_delta
          @card_drag = @waste.take
        end

        if card = @card_drag
          card.update(frame_time)

          if @card_drag_released
            if card.moved?
              @card_drag_to_stack.add(card)
              @card_drag = nil
              @card_drag_delta = Game::Vector.zero
              @card_drag_released = false
            end
          else
            card.x = Game::Mouse.x - @card_drag_delta.x
            card.y = Game::Mouse.y - @card_drag_delta.y

            unless Game::Mouse::Left.down?
              @card_drag_to_stack = @waste

              if fan_stack = @fan_stacks.find(&.mouse_in?)
                @card_drag_to_stack = fan_stack
              end

              card.move(@card_drag_to_stack.add_position)
              @card_drag_released = true
            end
          end
        end
      end

      def draw
        super
        @stock.draw
        @waste.draw
        @fan_stacks.each(&.draw)
        @cards.each(&.draw)

        if card = @card_drag
          card.draw
        end
      end

      def deal_fan_stack_index(prev_row = false)
        spaces = (@deal_row_index + 1).times.to_a.sum
        (@deal_index + spaces) % @fan_stacks.size
      end

      def deal
        @cards.select(&.moved?).each do |card|
          fan_stack_index = deal_fan_stack_index
          fan_stack = @fan_stacks[fan_stack_index]

          fan_stack.add(card)
          @cards.delete(card)

          card.flip if fan_stack.size >= fan_stack_index + 1

          @deal_row_index += 1 if fan_stack_index >= @fan_stacks.size - 1
          @deal_index += 1
        end

        return if @cards.any?(&.moving?)

        if @deal_index >= DEAL_CARDS
          @dealt = true
          return
        end

        card = @stock.take
        card.move(@fan_stacks[deal_fan_stack_index].add_position)
        @cards << card
      end
    end
  end
end
