module Cards
  class CardStack
    property position : Game::Vector
    property cards : Array(Card)

    delegate :x, :y, to: position
    delegate :size, :empty?, to: cards

    def initialize(x = 0, y = 0, @cards = [] of Card)
      @position = Game::Vector.new(
        x: x,
        y: y
      )

      update_cards_position
    end

    def update(frame_time)
      @cards.each(&.update(frame_time))
    end

    def draw(screen_x = 0, screen_y = 0)
      @cards.each(&.draw(screen_x, screen_y))
    end

    def add(card : Card)
      card.position.x = x
      card.position.y = y

      card.flip unless card.flipped?

      @cards << card

      update_cards_position
    end

    def update_cards_position
      @cards.each_with_index do |card, index|
        card.position.x = x
        card.position.y = y - index * Card.height_depth
      end
    end

    def take : Card
      @cards.pop
    end

    def shuffle!
      @cards.shuffle!
      update_cards_position
    end
  end
end
