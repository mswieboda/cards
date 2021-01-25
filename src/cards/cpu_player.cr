require "./seat_player"

module Cards
  class CpuPlayer < SeatPlayer
    MIN_BALANCE = 5
    BET = 5

    DONE_DELAY = 0.69_f32

    def playing_update(_frame_time)
      super

      # TODO: impl strategy, copy dealer's logic for now
      if hand = current_hand
        if hand.value >= 17 && !hand.soft_17?
          hand.stand
        else
          hand.hit unless hand.hitting?
        end
      end
    end

    def betting_update(_frame_time)
      super

      unless placing_bet?
        if hand = current_hand
          if !confirmed_bet? && @chips.empty? && hand.chip_stack_bet.any?
            confirm_bet
          elsif hand.chip_stack_bet.empty?
            if chip = chip_tray.largest(BET)
              place_bet(chip)
            else
              leave_table
            end
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
