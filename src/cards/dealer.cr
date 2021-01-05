module Cards
  class Dealer < CardPlayer
    CARD_SPOT_Y_RATIO = 6_f32

    ACTION_DELAY = 0.69_f32
    DONE_DELAY = 1.69_f32

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
      return unless super

      if playing? && !hitting?
        if card = cards[1]
          if card.flipped?
            card.flip
            delay(action_delay)
          else
            # drawing cards until the hand busts or achieves a value of 17 or higher
            # (a dealer total of 17 including an ace valued as 11, also known as a "soft 17", must be drawn to in some games and must stand in others).
            # The dealer never doubles, splits, or surrenders

            hand = hand_value

            puts ">>> #{self.class} playing, hand: #{hand_display} cards: #{cards.map(&.short_name)}" if Main::DEBUG

            if hand >= 17 && !soft_17?
              stand
            else
              hit
            end
          end
        end
      end
    end

    def action_delay
      ACTION_DELAY
    end

    def done_delay
      DONE_DELAY
    end
  end
end
