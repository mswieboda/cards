module Cards
  class CardStack
    property position : Game::Vector
    property cards : Array(Card)

    delegate :x, :y, to: position
    delegate :size, :empty?, :any?, to: cards

    @move_to : Nil | Game::Vector
    @move_delta : Game::Vector

    MOVEMENT_FRAMES = 16

    def initialize(x = 0, y = 0, @cards = [] of Card)
      @position = Game::Vector.new(
        x: x,
        y: y
      )

      @move_to = nil
      @move_delta = Game::Vector.new

      update_cards_position
    end

    def update(frame_time)
      @cards.each(&.update(frame_time))

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

          update_cards_position

          # if we're there, clear `move_to`
          @move_to = nil if @position.x == move_to.x && @position.y == move_to.y
        end
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      @cards.each(&.draw(screen_x, screen_y))
    end

    def x=(value : Int32 | Float32)
      @position.x = value
      update_cards_position
    end

    def y=(value : Int32 | Float32)
      @position.y = value
      update_cards_position
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

    def self.width
      Card.width
    end

    def self.height
      Card.height
    end

    def self.height_depth
      Card.height_depth
    end

    def width
      self.class.width
    end

    def height
      self.class.height + height_depth
    end

    def height_depth
      @cards.size * self.class.height_depth
    end

    def add_position
      Game::Vector.new(
        x: x,
        y: y - @cards.size * self.class.height_depth
      )
    end

    def add(card : Card)
      @cards << card

      update_cards_position
    end

    def add(card_stack : CardStack)
      @cards += card_stack.cards
      card_stack.cards = [] of Card
      @cards
    end

    def update_cards_position
      @cards.each_with_index do |card, index|
        card.position.x = x
        card.position.y = y - index * self.class.height_depth
      end
    end

    def mouse_in?
      Game::Mouse.in?(
        x: x,
        y: y - height_depth,
        width: width,
        height: height
      )
    end

    def pressed?
      mouse_in? && Game::Mouse::Left.pressed?
    end

    def take : Card
      @cards.pop
    end

    def take_sample : Card | Nil
      card = @cards.delete(@cards.sample)
      update_cards_position
      card
    end

    def take_pressed
      return unless pressed?
      return if empty?
      take
    end

    def take_pressed_stack
      return unless pressed?
      return if empty?

      index = @cards.index(&.mouse_in?)

      self.class.new(x: card.x, y: card.y, cards: @cards.delete_at(index..-1))
    end

    def shuffle!
      @cards.shuffle!
      update_cards_position
    end
  end
end
