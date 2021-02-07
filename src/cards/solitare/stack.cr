require "./stock"

module Cards
  module Solitare
    class Stack < Stock
      MARGIN_X = 0
      MARGIN_Y = 25

      DOUBLE_CLICK_MILLISECONDS = 333

      @[JSON::Field(ignore: true)]
      @last_click_time : Time::Span?
      @double_clicked = false

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

      def update(frame_time)
        super

        if pressed?
          now = Time.monotonic

          if last_click_time = @last_click_time
            elapsed = now - last_click_time
            @double_clicked = elapsed.total_milliseconds < DOUBLE_CLICK_MILLISECONDS
          else
            @double_clicked = false
          end

          @last_click_time = now
        end
      end

      def update_cards_position
        @cards.each_with_index do |card, index|
          card.position.x = margin_x.zero? ? x : x + index * margin_x
          card.position.y = margin_y.zero? ? y : y + index * (self.class.height_depth + margin_y)
        end
      end

      def add_position(index = @cards.size - 1)
        Game::Vector.new(
          x: x,
          y: y + (index + 1) * (self.class.height_depth + margin_y)
        )
      end

      def take_pressed_stack : Stack?
        return unless pressed?
        return if empty?

        index = @cards.reverse.index(&.mouse_in?)

        return unless index

        index = @cards.size - 1 - index
        card = @cards[index]

        Stack.new(x: card.x, y: card.y, cards: @cards.delete_at(index..-1))
      end

      def double_clicked?
        return false unless pressed?
        @double_clicked
      end

      def add?(stack : Stack, _auto = false)
        return false if stack.empty? || !mouse_in?
        return true if empty?

        top = @cards.last
        bottom = stack.cards.first

        top.rank.value == bottom.rank.value + 1 && !top.suit.pair?(bottom.suit)
      end

      def flip_up_top_card?
        return false if empty?
        return false unless double_clicked?

        top = @cards.last

        top.flipped?
      end

      def flip_up_top_card
        return if empty?

        top = @cards.last

        top.flip if top.flipped?
      end
    end
  end
end
