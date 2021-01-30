require "./seat_player"

module Cards
  class Player < SeatPlayer
    def playing_update(_frame_time)
      super

      if Key.stand.pressed?
        stand
      elsif Key.hit.pressed?
        hit
      elsif !doubling_bet? && can_double_bet?
        if Key.double_down.pressed?
          double_down
        elsif can_split? && Key.split.pressed?
          split
        end
      end
    end

    def betting_update(frame_time)
      super

      if chip = chip_tray.selected_chip
        place_bet(chip)
      end

      toggle_clear_bet if Key.clear_bet.pressed?
      confirm_bet if Game::Keys.pressed?(Key.confirm_bet_keys)
    end

    def toggle_clear_bet
      @clearing_bet = !@clearing_bet
    end
  end
end
