module Cards
  abstract class CardFront
    def draw(card : Card, screen_x, screen_y)
      draw_back(card, screen_x, screen_y)
      draw_heading(card, screen_x, screen_y)

      case card.rank
      when Rank::Ace
        draw_ace(card, screen_x, screen_y)
      else
        draw_ace(card, screen_x, screen_y)
      end

      if Main::DEBUG
        text = Game::Text.new(
          text: card.short_name,
          size: 10,
          spacing: 2,
          color: card.suit.color
        )

        # lower left corner
        spacing = 5
        text.x = screen_x + spacing
        text.y = screen_y + card.height - spacing - text.height

        text.draw
      end
    end

    def draw_back(card : Card, screen_x, screen_y)
      Game::Rectangle.new(
        x: screen_x,
        y: screen_y,
        width: card.width,
        height: card.height,
        color: Game::Color::Ivory
      ).draw
    end

    def draw_heading(card : Card, screen_x, screen_y)
    end

    def draw_ace(card : Card, screen_x, screen_y)
    end
  end
end
