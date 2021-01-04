module Cards
  class Dealer < CardPlayer
    CARD_SPOT_Y_RATIO = 6_f32

    def initialize
      card_spots = [] of CardSpot

      card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 - CardSpot.width - CardSpot.margin / 2_f32,
        y: Main.screen_height / CARD_SPOT_Y_RATIO - CardSpot.height / 2_f32
      )

      card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 + CardSpot.margin / 2_f32,
        y: Main.screen_height / CARD_SPOT_Y_RATIO - CardSpot.height / 2_f32
      )

      super(card_spots: card_spots)
    end

    def deal(card : Card)
      super

      # make sure 2nd card gets double flipped for dealer, staying covered
      card.flip if cards.size == 2 && !card.flipped?
    end
  end
end
