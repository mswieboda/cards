module Cards
  class Card
    property position : Game::Vector
    property deck : Deck
    property rank : Rank
    property suit : Suit
    property? flipped
    property? selected
    property move_to : Nil | Game::Vector

    delegate :x, :y, to: position

    # bicycle card size in mm from https://en.wikipedia.org/wiki/Standard_52-card_deck#Size_of_the_cards
    WIDTH = 64
    HEIGHT = 88

    MOVEMENT = 2

    def initialize(@deck, @rank, @suit, @flipped = true)
      @position = Game::Vector.new
      @selected = false
      @moved = false
    end

    def self.width
      WIDTH
    end

    def self.height
      HEIGHT
    end

    # methods for width/height in case of changing to instance vars later
    def width
      self.class.width
    end

    def height
      self.class.height
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

    def moving?
      !!@move_to
    end

    def moved?
      !moving?
    end

    def update(frame_time)
      if moving?
        if move_to = @move_to
          direction = move_to.subtract(position)

          # TODO: scale the direction to a unit of movement (like 2 pixels per frame etc)
          # then apply dx, dy of that direction to `position`
          # position.x +=

          # if we've reached or gone past `move_to`, set x, y and reset `move_to` to nil
          @position.x = move_to.x
          @position.y = move_to.y
          @move_to = nil
        end
      else
        if Game::Mouse::Left.pressed?
          mouse_x = Game::Mouse.x
          mouse_y = Game::Mouse.y

          if mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height
            @selected = true
          else
            @selected = false
          end
        end

        if selected?
          position.y -= MOVEMENT if Game::Keys.down?([Game::Key::W, Game::Key::Up])
          position.x -= MOVEMENT if Game::Keys.down?([Game::Key::A, Game::Key::Left])
          position.y += MOVEMENT if Game::Keys.down?([Game::Key::S, Game::Key::Down])
          position.x += MOVEMENT if Game::Keys.down?([Game::Key::D, Game::Key::Right])
        end
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      if flipped?
        @deck.back.draw(
          screen_x: screen_x + x,
          screen_y: screen_y + y,
          width: width,
          height: height
        )
      else
        @deck.front.draw(
          card: self,
          screen_x: screen_x + x,
          screen_y: screen_y + y
        )
      end

      if selected?
        Game::RoundedRectangle.new(
          x: screen_x + x,
          y: screen_y + y,
          width: width,
          height: height,
          roundness: 0.15_f32,
          thickness: 3,
          color: Game::Color::Blue,
          filled: false
        ).draw
      end
    end

    def to_s(io : IO)
      io << "#<#{self.class} "
      io << "rank: #{rank}, "
      io << "suit: #{suit}"
      io << ">"
    end
  end
end
