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
        chip_tray: ChipTray.new(
          y: Card.margin,
          balance: 3000,
        )
      )
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
        text.y -= (Card.margin + text.height).to_i

        text.draw

        return text.y
      end

      super
    end

    def update(_frame_time)
      super

      return if delay?

      if playing? && !hitting?
        if hand = current_hand
          if card = hand.cards[1]
            if card.flipped?
              card.flip
              delay(action_delay)
            else
              log(:update, "playing, hand: #{hand_display} cards: #{cards_short_name}")

              if hand.value >= 17 && !hand.soft_17?
                hand.stand
              else
                hand.hit
              end
            end
          end
        end
      end
    end

    def hand_display
      if hand = current_hand
        hand.value
      else
        0
      end
    end

    def hand_value
      if hand = current_hand
        hand.value
      else
        0
      end
    end

    def cards_short_name
      if hand = current_hand
        hand.cards_short_name
      else
        ""
      end
    end

    def bust?
      if hand = current_hand
        hand.bust?
      else
        false
      end
    end

    def blackjack?
      if hand = current_hand
        hand.blackjack?
      else
        false
      end
    end

    def deal(card_stack : CardStack)
      log(:deal)

      if hand = current_hand
        card = hand.deal(card_stack)
        card.flip if hand.size == 2 && !card.flipped?
        delay(deal_delay)
      end
    end

    def play(all_busted_or_blackjack)
      log(:play, "all_busted_or_blackjack: #{all_busted_or_blackjack}")

      if all_busted_or_blackjack
        # flip card, and end turn
        if hand = current_hand
          if card = hand.cards[1]
            if card.flipped?
              card.flip
              delay(action_delay)
            else
              hand.play_done
            end
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
