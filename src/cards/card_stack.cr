module Cards
  class CardStack
    property position : Game::Vector
    property cards : Array(Card)

    delegate :x, :y, to: position
    delegate :size, :empty?, :any?, to: cards

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

    def self.width
      Card.width
    end

    def self.height
      Card.height
    end

    def width
      self.class.width
    end

    def height
      self.class.height + height_depth
    end

    def height_depth
      @cards.size * Card.height_depth
    end

    def add_position
      Game::Vector.new(
        x: x,
        y: y - @cards.size * Card.height_depth
      )
    end

    def add(card : Card, flipped = true)
      card.flip if flipped && !card.flipped?

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

    def take_sample : Card | Nil
      card = @cards.delete(@cards.sample)
      update_cards_position
      card
    end

    def shuffle!
      @cards.shuffle!
      update_cards_position
    end
  end
end
