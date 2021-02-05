module Cards
  class Card
    property position : Game::Vector
    property rank : Rank
    property suit : Suit
    property? flipped

    delegate :x, :x=, :y, :y=, to: position

    @move_to : Nil | Game::Vector
    @move_delta : Game::Vector

    # bicycle card size in mm from https://en.wikipedia.org/wiki/Standard_52-card_deck#Size_of_the_cards
    WIDTH = 64
    HEIGHT = 88
    HEIGHT_DEPTH = 0.666_f32
    MARGIN = 10

    DROP_SHADOW = 1

    MOVEMENT_FRAMES = 16

    def initialize(@rank, @suit, @flipped = true, @position = Game::Vector.new)
      @move_to = nil
      @move_delta = Game::Vector.new
    end

    def self.width
      WIDTH
    end

    def self.height
      HEIGHT
    end

    def self.height_depth
      HEIGHT_DEPTH
    end

    def self.margin
      MARGIN
    end

    def clone : Card
      Card.new(
        rank: rank,
        suit: suit,
        flipped: flipped?,
        position: position.clone
      )
    end

    # methods for width/height in case of changing to instance vars later
    def width
      self.class.width
    end

    def height
      self.class.height
    end

    def height_depth
      self.class.height_depth
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

    def mouse_in?
      Game::Mouse.in?(
        x: x,
        y: y,
        width: width,
        height: height
      )
    end

    def moving?
      !!@move_to
    end

    def moved?
      !moving?
    end

    def move(move_to : Game::Vector, frames = MOVEMENT_FRAMES)
      @move_to = move_to.clone
      @move_delta = (move_to - position) / frames
    end

    def update(frame_time)
      if moving?
        if move_to = @move_to
          @position.x += @move_delta.x
          @position.y += @move_delta.y

          # if we've reached or gone past `move_to`, snap to it
          if (@move_delta.x.sign >= 0 && @move_delta.x + @position.x >= move_to.x) ||
            (@move_delta.x.sign < 0 && @move_delta.x + @position.x <= move_to.x)
            @position.x = move_to.x
          end

          if (@move_delta.y.sign >= 0 && @move_delta.y + @position.y >= move_to.y) ||
            (@move_delta.y.sign < 0 && @move_delta.y + @position.y <= move_to.y)
            @position.y = move_to.y
          end

          # if we're there, clear `move_to`
          @move_to = nil if @position.x == move_to.x && @position.y == move_to.y
        end
      end
    end

    def draw(deck, screen_x = 0, screen_y = 0)
      draw_shadow(screen_x, screen_y)

      if flipped?
        deck.back.draw(
          screen_x: screen_x + x,
          screen_y: screen_y + y,
          width: width,
          height: height
        )
      else
        deck.front.draw(
          card: self,
          screen_x: screen_x + x,
          screen_y: screen_y + y
        )
      end
    end

    def draw_shadow(screen_x, screen_y)
      Game::RoundedRectangle.new(
        x: screen_x + x - DROP_SHADOW,
        y: screen_y + y - DROP_SHADOW,
        width: width + DROP_SHADOW * 2,
        height: height + DROP_SHADOW * 2,
        roundness: 0.15_f32,
        color: Game::Color::Black.alpha(33_u8),
      ).draw
    end

    def to_s(io : IO)
      io << "#<#{self.class} "
      io << "rank: #{rank}, "
      io << "suit: #{suit}"
      io << ">"
    end
  end
end
