module Cards
  class Card
    property deck : Deck
    property rank : Rank
    property suit : Suit
    property? flipped

    # bicycle card size in mm from https://en.wikipedia.org/wiki/Standard_52-card_deck#Size_of_the_cards
    WIDTH = 63
    HEIGHT = 88

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
        @deck.back.draw(
          screen_x: screen_x,
          screen_y: screen_y,
          width: width,
          height: height
        )
      else
        @deck.front.draw(
          card: self,
          screen_x: screen_x,
          screen_y: screen_y
        )
      end
    end
  end
end
