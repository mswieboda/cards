module Cards
  module Solitare
    class Stack < CardStack
      getter? hovered
      getter pressed_delta : Game::Vector

      MARGIN_X = 0
      MARGIN_Y = 25

      def initialize(x = 0, y = 0, @cards = [] of Card)
        super

        @hovered = false
        @pressed_delta = Game::Vector.zero
      end

      def update(frame_time)
        super

        @hovered = false
        @pressed_delta = Game::Vector.zero

        if @cards.any?
          card = @cards.last

          @hovered = card.mouse_in?

          if hovered? && Game::Mouse::Left.pressed?
            @pressed_delta = Game::Mouse.position - card.position
          end
        end
      end

      def draw(screen_x = 0, screen_y = 0)
        super

        if Main::DEBUG && @cards.any? && hovered?
          card = @cards.last
          Game::RoundedRectangle.new(
            x: screen_x + card.x,
            y: screen_y + card.y,
            width: card.width,
            height: card.height,
            roundness: 0.15_f32,
            thickness: 3,
            filled: false,
            color: pressed? ? Game::Color::Purple : Game::Color::Yellow
          ).draw
        end
      end

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

      def pressed?
        !@pressed_delta.zero?
      end

      def update_cards_position
        @cards.each_with_index do |card, index|
          card.position.x = margin_x.zero? ? x : x + index * margin_x
          card.position.y = margin_y.zero? ? y : y + index * (Card.height_depth + margin_y)
        end
      end

      def add_position
        Game::Vector.new(
          x: x,
          y: y + @cards.size * (Card.height_depth + margin_y)
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
