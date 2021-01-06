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
            puts ">>> #{self.class} playing, hand: #{hand_display} cards: #{cards.map(&.short_name)}" if Main::DEBUG

            if hand_value >= 17 && !soft_17?
              stand
            else
              hit
            end
          end
        end
      end
    end

    def play(all_busted_or_blackjack)
      puts ">>> #{self.class}#play all_busted_or_blackjack: #{all_busted_or_blackjack}" if Main::DEBUG

      if all_busted_or_blackjack
        # flip card, and end turn
        if card = cards[1]
          if card.flipped?
            card.flip
            play_done
            delay(action_delay)
          end
        end
      else
        play
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
