module Cards
  class Stack
    property x : Int32
    property y : Int32
    property cards : Array(Card)

    def initialize(@x = 0, @y = 0, @cards = [] of Card)
      @cards.each do |card|
        card.position.x = x
        card.position.y = y
      end
    end

    def update(frame_time)
      @cards.each(&.update(frame_time))
    end

    def draw(screen_x = 0, screen_y = 0)
      return if cards.empty?
      # draw top card
      # TODO: draw shadow bottom/right to show depth if more than 1 card?
      cards[-1].draw(screen_x, screen_y)
    end

    def add(card : Card)
      card.position.x = x
      card.position.y = y

      @cards << card
    end

    def take : Card
      @cards.pop
    end

    def shuffle!
      @cards.shuffle!
    end
  end
end
