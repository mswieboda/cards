module Cards
  class Dealer < CardPlayer
    CARD_SPOT_Y_RATIO = 6_f32

    ACTION_DELAY = 0.3
    DONE_DELAY = 0.5

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

    def update(_frame_time)
      super

      if playing?
        if card = cards[1]
          if card.flipped?
            sleep ACTION_DELAY
            card.flip
          else
            sleep ACTION_DELAY
            stand
            sleep ACTION_DELAY
          end
        end
      end
    end
  end
end
