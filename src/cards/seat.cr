module Cards
  class Seat
    getter position : Game::Vector
    getter card_spots : Array(CardSpot)
    property player : CardPlayer | Nil

    delegate :x, :y, to: position

    def initialize(x : Int32 | Float32 = 0, y : Int32 | Float32 = 0)
      @position = Game::Vector.new(x: x, y: y)
      @card_spots = [] of CardSpot
      @card_spots << CardSpot.new(
        x: @position.x - CardSpot.margin / 2_f32 - CardSpot.width,
        y: @position.y
      )
      @card_spots << CardSpot.new(
        x: @position.x + CardSpot.margin / 2_f32,
        y: @position.y
      )
      @player = nil
    end

    def no_seat?
      x.zero? && y.zero?
    end

    def draw(screen_x = 0, screen_y = 0)
      return unless Main::DEBUG

      card_spots.each(&.draw(screen_x, screen_y))
    end

    def player?
      !!player
    end
  end
end
