module Cards
  module Solitare
    class Waste < CardStack
      getter? hovered
      getter pressed_delta : Game::Vector

      PEEK = 15

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

          @hovered = Game::Mouse.in?(
            x: card.x,
            y: card.y,
            width: card.width,
            height: card.height
          )

          if hovered? && Game::Mouse::Left.pressed?
            # TODO: switch to Game::Mouse.position when added/published
            # TODO: switch to Vector#-(vector : Vector) when added/published (via macros)
            @pressed_delta = Game::Vector.new(x: Game::Mouse.x, y: Game::Mouse.y).subtract(card.position)
          end
        end
      end

      def draw(screen_x = 0, screen_y = 0)
        super

        if hovered?
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

      def pressed?
        !@pressed_delta.zero?
      end

      def update_cards_position
        @cards.each_with_index do |card, index|
          card.position.x = x + index * PEEK
          card.position.y = y
        end
      end

      def add_position
        Game::Vector.new(
          x: x + @cards.size * PEEK,
          y: y
        )
      end
    end
  end
end
