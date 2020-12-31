require "./game_mode"

module Cards
  class Blackjack < GameMode
    MARGIN = 10

    def initialize
      super

      @deck = StandardDeck.new(jokers: true)
    end

    def update(frame_time)
      if Game::Key::Space.pressed?
        @deck.cards.each(&.flip)
      end
    end

    def draw
      super

      draw_row_of_cards
    end

    def draw_row_of_cards
      x = MARGIN
      y = MARGIN

      @deck.cards.each_with_index do |card, index|
        card.draw(screen_x: x, screen_y: y)

        x += card.width + MARGIN

        if x + card.width + MARGIN > Main.screen_width
          x = MARGIN
          y += MARGIN + card.height
        end
      end
    end
  end
end
