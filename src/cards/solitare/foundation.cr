require "./waste"

module Cards
  module Solitare
    class Foundation < Waste
      getter suit : Suit

      @[JSON::Field(converter: Cards::Solitare::FoundationSpriteConverter)]
      @sprite : Game::Sprite

      MARGIN_X = 0
      MARGIN_Y = 0

      def initialize(@suit, x = 0, y = 0, cards = [] of Card)
        super(x: x, y: y, cards: cards)

        @sprite = Game::Sprite.get(suit.sprite_sym).resize(32, 32)
      end

      def draw(deck : Deck, screen_x = 0, screen_y = 0)
        super

        if empty?
          @sprite.draw(
            x: screen_x + x + width / 2_f32,
            y: screen_y + y + height / 2_f32,
            centered: true,
            tint: Game::Color::Black.alpha(33_u8)
          )
        end
      end

      def self.margin_x
        MARGIN_X
      end

      def self.margin_y
        MARGIN_Y
      end

      def add_position(index = @cards.size - 1)
        Game::Vector.new(
          x: x,
          y: y - (index + 1) * self.class.height_depth
        )
      end

      def mouse_in?
        Game::Mouse.in?(
          x: x,
          y: y,
          width: width,
          height: height
        )
      end

      def add?(stack : Stack)
        return false if stack.size != 1

        bottom = stack.cards.first

        return false unless bottom.suit == suit
        return bottom.rank.ace? if empty?

        top = @cards.last

        bottom.rank.value == top.rank.value + 1
      end

      def add?(card : Card)
        return false unless card.suit == suit
        return card.rank.ace? if empty?

        top = @cards.last

        card.rank.value == top.rank.value + 1
      end
    end

    module FoundationSpriteConverter
      def self.from_json(value : JSON::PullParser) : Game::Sprite
        Game::Sprite.get(Cards::Suit.sym_from_sprite_string(value.read_string)).resize(32, 32)
      end

      def self.to_json(value : Game::Sprite, json : JSON::Builder)
        json.string(value.name)
      end
    end
  end
end
