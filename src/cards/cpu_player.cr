require "./seat_player"

module Cards
  class CpuPlayer < SeatPlayer
    MIN_BALANCE = 5
    BET = 5

    def update(_frame_time)
      return unless super

      unless confirmed_bet?
        unless placing_bet?
          if place_bet(BET)
            # TODO: add chip to chip stack, etc
            @placing_bet = false
            confirm_bet
          else
            # means they don't have enough balance for the bet, stop placing
            @placing_bet = false
            confirm_bet
          end
        end
      end

      if playing?
        # TODO: impl strategy or copy dealer's logic for now
        if hand_value >= 17 && !soft_17?
          stand
        else
          hit
        end

        delay(action_delay)
      end
    end

    def confirm_bet
      super

      # means they don't have enough balance for the bet
      unless confirmed_bet?
        if balance <= MIN_BALANCE
          leave_table
        end
      end

      delay(action_delay)
    end
  end
end
