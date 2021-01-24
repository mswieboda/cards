require "./seat_player"

module Cards
  class Player < SeatPlayer
    def playing_update(_frame_time)
      if Key.stand.pressed?
        stand
      elsif Key.hit.pressed?
        hit
      end
    end

    def betting_update(frame_time)
      super

      chip_tray.update(frame_time)

      if chip = chip_tray.selected_chip
        place_bet(chip)
      end

      confirm_bet if Game::Keys.pressed?(Key.confirm_bet_keys)
    end
  end
end
