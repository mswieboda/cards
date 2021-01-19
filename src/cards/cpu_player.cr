require "./seat_player"

module Cards
  class CpuPlayer < SeatPlayer
    MIN_BALANCE = 5
    BET = 5

    def playing_update(_frame_time)
      # TODO: impl strategy, copy dealer's logic for now
      if hand_value >= 17 && !soft_17?
        stand
      else
        hit
      end
    end

    def betting_update(_frame_time)
      super

      unless placing_bet?
        if chip = Chip.largest(BET)
          if place_bet(chip.value)
            @placing_bet = true
            chip.move(@chip_stack_bet.add_chip_position)
            @chips << chip
          end
        else
          # shouldn't happen, unless BET is < min Chip::Amount
          raise "CpuPlayer bet of #{BET}, no chips found"
        end
      end

      if @chips.empty? && !confirmed_bet?
        @placing_bet = false
        confirm_bet
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
