module Cards
  class Seat
    getter position : Game::Vector
    property player : CardPlayer | Nil

    delegate :x, :y, to: position

    def initialize(x : Int32 | Float32 = 0, y : Int32 | Float32 = 0)
      @position = Game::Vector.new(x: x, y: y)
      @player = nil
    end

    def no_seat?
      x.zero? && y.zero?
    end

    def player?
      !!player
    end
  end
end
