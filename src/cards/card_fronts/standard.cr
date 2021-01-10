require "../card_front"

module Cards::CardFronts
  class Standard < CardFront
    SPACING = 10

    @@sprites = {} of String => Game::Sprite
    @@headings = {} of String => Hash(String, Game::Image)
    @@images = {} of String => Hash(String, Game::Image)
    @@textures = {} of String => Hash(String, Game::Texture)

    def initialize
      Suit.each do |suit|
        @@sprites["heading_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(10, 10)
        @@sprites["ace_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(32, 32)
        @@sprites["numeral_" + suit.to_s] = Game::Sprite.get(suit.sprite_sym).resize(14, 14)

        @@headings[suit.to_s] = {} of String => Game::Image
        @@images[suit.to_s] = {} of String => Game::Image
        @@textures[suit.to_s] = {} of String => Game::Texture

        Rank.each do |rank|
          label = Game::Image.from_text(
            text: rank.short_name,
            font_size: 10,
            spacing: 2,
            color: suit.color
          )
          label.flip_horizontal!
          label.flip_vertical!

          @@headings[suit.to_s][rank.to_s] = label
        end

        Rank.each do |rank|
          image = Game::Image.from_size(width, height)

          draw_heading(image, suit, rank)
          draw_rank(image, suit, rank)

          @@images[suit.to_s][rank.to_s] = image
          @@textures[suit.to_s][rank.to_s] = Game::Texture.load(image)
        end
      end
    end

    def draw(card : Card, screen_x, screen_y)
      super

      texture = @@textures[card.suit.to_s][card.rank.to_s]

      texture.draw(x: screen_x, y: screen_y)
    end

    def draw_heading(image : Game::Image, suit : Suit, rank : Rank)
      if rank.joker?
        draw_joker_heading(image, suit, rank)
        return
      end

      # draw label
      spacing = 3
      x = spacing
      y = spacing
      sprite = @@sprites["heading_" + suit.to_s]

      text = Game::Text.new(
        text: rank.short_name,
        size: 10,
        spacing: 2,
        color: suit.color
      )

      text.x = x + ((sprite.width - text.width) / 2).to_i
      text.y = y

      image.draw(text)

      # draw suit
      x += sprite.width / 2
      y += text.height + sprite.height / 2

      sprite.draw(image: image, x: x, y: y, centered: true)

      # draw label, flipped
      label = @@headings[suit.to_s][rank.to_s]
      x = width - spacing - label.width - ((sprite.width - label.width) / 2).to_i
      y = height - spacing - label.height

      image.draw(image: label, x: x, y: y)

      # draw suit, flipped
      x = width - spacing - sprite.width / 2
      y -= sprite.height / 2

      sprite.draw(image: image, x: x, y: y, centered: true, flip_vertical: true, flip_horizontal: true)
    end

    def draw_joker_heading(image : Game::Image, suit : Suit, rank : Rank)
      spacing = 3
      x = spacing
      y = spacing

      %w(J O K E R).each do |label|
        text = Game::Text.new(
          text: label,
          size: 10,
          spacing: 0,
          color: suit.color
        )

        text.x = x
        text.y = y

        image.draw(text)

        y += text.height - 1
      end
    end

    def draw_numeral(image : Game::Image, suit : Suit, rank : Rank)
      sprite = @@sprites["numeral_" + suit.to_s]
      heading = 13
      spacing = 5
      spacing_v = 2

      if rank.two? || rank.three?
        x = width / 2
        y = spacing + sprite.height

        sprite.draw(image: image, x: x, y: y, centered: true)

        y = height - spacing - sprite.height

        sprite.draw(image: image, x: x - 1, y: y, centered: true, flip_vertical: true, flip_horizontal: true)
      else
        spacing_h = 1
        x = heading + spacing_h + sprite.width / 2
        y = spacing + sprite.height

        sprite.draw(image: image, x: x, y: y, centered: true)

        y = height - spacing - sprite.height

        sprite.draw(image: image, x: x, y: y, centered: true, flip_vertical: true, flip_horizontal: true)

        x = width - heading - spacing_h - sprite.width / 2
        y = spacing + sprite.height

        sprite.draw(image: image, x: x, y: y, centered: true)

        y = height - spacing - sprite.height

        sprite.draw(image: image, x: x, y: y, centered: true, flip_vertical: true, flip_horizontal: true)
      end

      if rank.three? || rank.five? || rank.nine?
        x = width / 2
        y = height / 2

        sprite.draw(image: image, x: x, y: y, centered: true)
      elsif rank.six? || rank.seven? || rank.eight?
        spacing_h = 1
        x = heading + spacing_h + sprite.width / 2
        y = height / 2

        sprite.draw(image: image, x: x, y: y, centered: true)

        x = width - heading - spacing_h - sprite.width / 2

        sprite.draw(image: image, x: x, y: y, centered: true)
      end

      if rank.seven? || rank.eight?
        x = width / 2
        y = height / 3 + spacing_v

        sprite.draw(image: image, x: x, y: y, centered: true)

        if rank.eight?
          x = width / 2
          y = height - height / 3 - spacing_v

          sprite.draw(image: image, x: x - 1, y: y, centered: true, flip_vertical: true, flip_horizontal: true)
        end
      elsif rank.nine? || rank.ten?
        spacing_h = 1
        x = heading + spacing_h + sprite.width / 2
        y = spacing + sprite.height * 2 + spacing_v

        sprite.draw(image: image, x: x, y: y, centered: true)

        y = height - spacing - sprite.height * 2 - spacing_v

        sprite.draw(image: image, x: x, y: y, centered: true, flip_vertical: true, flip_horizontal: true)

        x = width - heading - spacing_h - sprite.width / 2
        y = spacing + sprite.height * 2 + spacing_v

        sprite.draw(image: image, x: x, y: y, centered: true)

        y = height - spacing - sprite.height * 2 - spacing_v

        sprite.draw(image: image, x: x, y: y, centered: true, flip_vertical: true, flip_horizontal: true)


        if rank.ten?
          x = width / 2
          y = height / 3 - spacing_v

          sprite.draw(image: image, x: x, y: y, centered: true)

          x = width / 2
          y = height - height / 3 + spacing_v

          sprite.draw(image: image, x: x - 1, y: y, centered: true, flip_vertical: true, flip_horizontal: true)
        end
      end
    end

    def draw_face(image : Game::Image, suit : Suit, rank : Rank)
      text = Game::Text.new(
        text: rank.name,
        size: 10,
        spacing: 2,
        color: suit.color
      )

      text.x = (width / 2 - text.width / 2).to_i
      text.y = (height / 2 - text.height / 2).to_i

      image.draw(text)
    end

    def draw_ace(image : Game::Image, suit : Suit, rank : Rank)
      sprite = @@sprites["ace_" + suit.to_s]

      sprite.draw(
        image: image,
        x: width / 2,
        y: height / 2,
        centered: true
      )
    end

    def draw_joker(image : Game::Image, suit : Suit, rank : Rank)
    end
  end
end
