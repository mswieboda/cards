module Cards
  abstract class SeatPlayer < CardPlayer
    getter? placed_bet

    def initialize(card_spots = [] of CardSpot)
      super(card_spots: card_spots)

      @placed_bet = false
    end

    def new_hand
      super

      @placed_bet = false
    end
  end
end
