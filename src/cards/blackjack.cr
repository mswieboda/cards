require "./game_mode"

module Cards
  class Blackjack < GameMode
    MARGIN = 10

    def initialize
      super

      @deck = StandardDeck.new(jokers: true)
      layout_cards
    end

    def update(frame_time)
      @deck.update(frame_time)

      if Game::Key::Space.pressed?
        @deck.shuffle!
        @deck.cards.each(&.flip)
        layout_cards
      end
    end

    def draw
      super

      @deck.draw
    end

    def layout_cards
      x = MARGIN
      y = MARGIN

      @deck.cards.each_with_index do |card, index|
        card.x = x
        card.y = y

        x += card.width + MARGIN

        if x + card.width + MARGIN > Main.screen_width
          x = MARGIN
          y += MARGIN + card.height
        end
      end
    end
  end
end
