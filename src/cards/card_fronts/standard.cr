require "../card_front"

module Cards::CardFronts
  class Standard < CardFront
    SPACING = 10

    @@sprites = {} of String => Game::Sprite

    def initialize
      Suit.each do |suit|
        @@sprites["heading_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(10, 10)
        @@sprites["ace_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(32, 32)
        @@sprites["numeral_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(16, 16)
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
      if card.rank.joker?
        draw_joker_heading(card, screen_x, screen_y)
        return
      end

      # draw label
      spacing = 5
      x = screen_x + spacing
      y = screen_y + spacing
      sprite = @@sprites["heading_" + card.suit.to_s]

      text = Game::Text.new(
        text: card.rank.short_name,
        size: 10,
        spacing: 2,
        color: card.suit.color
      )

      # puts ">>> text: #{card.rank.short_name} width: #{text.width}"

      text.x = x + ((sprite.width - text.width) / 2).to_i
      text.y = y

      text.draw

      # draw suit
      y += text.height + 2

      sprite.draw(x: x, y: y)
    end

    def draw_joker_heading(card : Card, screen_x, screen_y)
      spacing = 5
      x = screen_x + spacing
      y = screen_y + spacing

      %w(J O K E R).each do |label|
        text = Game::Text.new(
          text: label,
          size: 10,
          spacing: 0,
          color: card.suit.color
        )

        text.x = x
        text.y = y

        text.draw

        y += text.height - 1
      end
    end

    def draw_rank(card : Card, screen_x, screen_y)
      spacing = 3

      case card.rank
      when .ace?
        sprite = @@sprites["ace_" + card.suit.to_s]
        x = screen_x + card.width / 2 - sprite.width / 2
        y = screen_y + card.height / 2 - sprite.height / 2

        sprite.draw(x: x, y: y)
      when .two?, .three?
        sprite = @@sprites["numeral_" + card.suit.to_s]
        x = screen_x + card.width / 2
        y = screen_y + spacing + sprite.height

        sprite.draw(x: x, y: y, centered: true)

        y = screen_y + card.height - spacing - sprite.height

        sprite.draw(x: x - 1, y: y, rotation: 180, centered: true)

        if card.rank.three?
          x = screen_x + card.width / 2
          y = screen_y + card.height / 2

          sprite.draw(x: x, y: y, centered: true)
        end
      else
        # raise "CardFronts::Standard#draw_rank error rank not found: #{card.rank}"
      end
    end
  end
end
