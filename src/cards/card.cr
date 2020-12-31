module Cards
  class Card
    property deck : Deck
    property rank : Rank
    property suit : Suit
    property? flipped

    # bicycle card size in mm from https://en.wikipedia.org/wiki/Standard_52-card_deck#Size_of_the_cards
    WIDTH = 63
    HEIGHT = 88

    TEXT_SIZE = 16

    def initialize(@deck, @rank, @suit, @flipped = false)
    end

    # methods for width/height in case of changing to instance vars later
    def width
      WIDTH
    end

    def height
      HEIGHT
    end

    def flip
      @flipped = !@flipped
    end

    def name
      rank.joker? ? rank.name : "#{rank.name} of #{suit.name}"
    end

    def short_name
      rank.joker? ? rank.short_name : rank.short_name + suit.short_name
    end

    def update(frame_time)

    end

    def draw(screen_x, screen_y)
      if flipped?
        # draw back
        @deck.back.draw(
          screen_x: screen_x,
          screen_y: screen_y,
          width: width,
          height: height
        )

        return
      end

      # fill
      Game::Rectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        color: Game::Color::Ivory
      ).draw

      draw_suit_rank(screen_x, screen_y)

      # border
      Game::Rectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        color: Game::Color::Black,
        filled: false
      ).draw
    end

    def draw_suit_rank(screen_x, screen_y)
      text = Game::Text.new(
        text: short_name,
        size: TEXT_SIZE,
        spacing: 5,
        color: suit.color
      )

      # center horz/vert
      text.x = screen_x + width / 2 - text.width / 2
      text.y = screen_y + height / 2 - text.height / 2

      text.draw
    end
  end
end
