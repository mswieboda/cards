require "../card_front"

module Cards::CardFronts
  class Standard < CardFront
    SPACING = 10

    @@sprites = {} of String => Game::Sprite

    def initialize
      Suit.each do |suit|
        @@sprites["heading_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(10, 10)
        @@sprites["ace_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(32, 32)
        @@sprites["numeral_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(14, 14)
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
      spacing = 3
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
      spacing = 3
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
      heading = 13
      spacing = 5
      sprite = @@sprites["numeral_" + card.suit.to_s]

      if card.rank.ace?
        sprite = @@sprites["ace_" + card.suit.to_s]
        x = screen_x + card.width / 2
        y = screen_y + card.height / 2

        sprite.draw(x: x, y: y, centered: true)
      elsif card.rank.two? || card.rank.three?
        x = screen_x + card.width / 2
        y = screen_y + spacing + sprite.height

        sprite.draw(x: x, y: y, centered: true)

        y = screen_y + card.height - spacing - sprite.height

        sprite.draw(x: x - 1, y: y, rotation: 180, centered: true)
      elsif card.rank.numeral?
        spacing_h = 1
        x = screen_x + heading + spacing_h + sprite.width / 2
        y = screen_y + spacing + sprite.height
        sprite.draw(x: x, y: y, centered: true)

        y = screen_y + card.height - spacing - sprite.height
        sprite.draw(x: x, y: y, rotation: 180, centered: true)

        x = screen_x + card.width - heading - spacing_h - sprite.width / 2
        y = screen_y + spacing + sprite.height
        sprite.draw(x: x, y: y, centered: true)

        y = screen_y + card.height - spacing - sprite.height
        sprite.draw(x: x, y: y, rotation: 180, centered: true)
      end

      if card.rank.three? || card.rank.five? || card.rank.nine?
        x = screen_x + card.width / 2
        y = screen_y + card.height / 2

        sprite.draw(x: x, y: y, centered: true)
      elsif card.rank.six? || card.rank.seven? || card.rank.eight?
        spacing_h = 1
        x = screen_x + heading + spacing_h + sprite.width / 2
        y = screen_y + card.height / 2
        sprite.draw(x: x, y: y, centered: true)

        x = screen_x + card.width - heading - spacing_h - sprite.width / 2
        sprite.draw(x: x, y: y, centered: true)
      end

      spacing_v = 2

      if card.rank.seven? || card.rank.eight?
        x = screen_x + card.width / 2
        y = screen_y + card.height / 3 + spacing_v
        sprite.draw(x: x, y: y, centered: true)
      end

      if card.rank.eight?
        x = screen_x + card.width / 2
        y = screen_y + card.height - card.height / 3 - spacing_v
        sprite.draw(x: x - 1, y: y, rotation: 180, centered: true)
      end

      if card.rank.nine? || card.rank.ten?
        spacing_h = 1
        x = screen_x + heading + spacing_h + sprite.width / 2
        y = screen_y + spacing + sprite.height * 2 + spacing_v
        sprite.draw(x: x, y: y, centered: true)

        y = screen_y + card.height - spacing - sprite.height * 2 - spacing_v
        sprite.draw(x: x, y: y, rotation: 180, centered: true)

        x = screen_x + card.width - heading - spacing_h - sprite.width / 2
        y = screen_y + spacing + sprite.height * 2 + spacing_v
        sprite.draw(x: x, y: y, centered: true)

        y = screen_y + card.height - spacing - sprite.height * 2 - spacing_v
        sprite.draw(x: x, y: y, rotation: 180, centered: true)
      end

      if card.rank.ten?
        x = screen_x + card.width / 2
        y = screen_y + card.height / 3 - spacing_v
        sprite.draw(x: x, y: y, centered: true)

        x = screen_x + card.width / 2
        y = screen_y + card.height - card.height / 3 + spacing_v
        sprite.draw(x: x - 1, y: y, rotation: 180, centered: true)
      end
    end
  end
end
