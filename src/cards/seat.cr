module Cards
  class Seat
    getter card_spots : Array(CardSpot)

    def initialize(@card_spots = [] of CardSpot)
    end

    def draw(screen_x = 0, screen_y = 0)
      return unless Main::DEBUG

      card_spots.each(&.draw(screen_x, screen_y))
    end
  end
end
