require "./seat_player"

module Cards
  class CpuPlayer < SeatPlayer
    MIN_BALANCE = 5
    BET = 5

    DONE_DELAY = 0.69_f32

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
        if !confirmed_bet? && @chips.empty? && @chip_stack_bet.any?
          confirm_bet
        elsif @chip_stack_bet.empty?
          if chip = chip_tray.largest(BET)
            place_bet(chip)
          else
            leave_table
          end
        end
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

    def done_delay
      DONE_DELAY
    end
  end
end
