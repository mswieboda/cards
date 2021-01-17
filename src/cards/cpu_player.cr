require "./seat_player"

module Cards
  class CpuPlayer < SeatPlayer
    MIN_BALANCE = 5

    def update(_frame_time)
      return unless super

      if placed_bet?
        if placing_bet?
          # check if bet is done being placed
          @placing_bet = false
        end
      else
        # TODO: randomize cpu betting, and base off of balance, etc
        place_bet
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

    def place_bet(bet = 1)
      super

      @placing_bet = true

      # means they don't have enough balance for the bet
      unless placed_bet?
        if balance <= MIN_BALANCE
          leave_table
        end
      end

      delay(action_delay)
    end
  end
end
