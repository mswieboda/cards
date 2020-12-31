require "./game_mode"

module Cards
  class Blackjack < GameMode
    @cards : Array(Card)

    MARGIN = 10

    def initialize
      super

      @cards = [] of Card
      @cards << Card.new(rank: Rank::Ace, suit: Suit::Spades)
      @cards << Card.new(rank: Rank::King, suit: Suit::Clubs)
      @cards << Card.new(rank: Rank::Three, suit: Suit::Hearts)
    end

    def update(frame_time)
      if Game::Key::Space.pressed?
        @cards.each(&.flip)
      end
    end

    def draw
      super

      draw_row_of_cards
    end

    def draw_row_of_cards
      x = MARGIN
      y = MARGIN

      @cards.each_with_index do |card, index|
        card.draw(screen_x: x, screen_y: y)

        x += card.width + MARGIN
      end
    end
  end
end
