module Cards
  class Dealer < CardPlayer
    CARD_SPOT_Y_RATIO = 6_f32

    ACTION_DELAY = 0.69_f32
    DONE_DELAY = 1.69_f32

    def initialize
      seat = Seat.new(
        x: Main.screen_width / 2_f32,
        y: Main.screen_height / CARD_SPOT_Y_RATIO
      )

      super(
        seat: seat,
        chip_tray: ChipTray.new(y: CardSpot.margin)
      )
    end

    def draw(screen_x = 0, screen_y = 0)
      seat.draw(screen_x, screen_y)

      super
    end

    def draw_hand_display(screen_x = 0, screen_y = 0, y = seat.y)
      unless playing? || played?
        mid_x = seat.x

        text = Game::Text.new(
          text: "",
          x: (screen_x + mid_x).to_i,
          y: y.to_i,
          size: 10,
          spacing: 2,
          color: Game::Color::Black,
        )

        text.x -= (text.width / 2_f32).to_i
        text.y -= (CardSpot.margin + text.height).to_i

        text.draw

        return text.y
      end

      super
    end

    def update(_frame_time)
      super

      return if delay?

      if playing? && !hitting?
        if card = cards[1]
          if card.flipped?
            card.flip
            delay(action_delay)
          else
            log(:update, "playing, hand: #{hand_display} cards: #{cards.map(&.short_name)}")

            if hand_value >= 17 && !soft_17?
              stand
            else
              hit
            end
          end
        end
      end
    end

    def deal(card : Card)
      super

      # make sure 2nd card gets double flipped for dealer, staying covered
      card.flip if cards.size == 2 && !card.flipped?
    end

    def play(all_busted_or_blackjack)
      log(:play, "all_busted_or_blackjack: #{all_busted_or_blackjack}")

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
