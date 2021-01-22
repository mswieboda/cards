require "./seat_player"

module Cards
  class Player < SeatPlayer
    def playing_update(_frame_time)
      if Game::Key::Space.pressed?
        stand
      elsif Game::Key::Enter.pressed?
        hit
      end
    end

    def betting_update(frame_time)
      super

      chip_tray.update(frame_time)

      if chip = chip_tray.selected_chip
        if place_bet(chip.value)
          @placing_bet = true
          chip.move(@chip_stack_bet.add_chip_position)
          @chips << chip
        end
      end

      @placing_bet = false if @chips.empty?

      confirm_bet if Game::Keys.pressed?([Game::Key::Space, Game::Key::LShift, Game::Key::RShift, Game::Key::Enter])
    end
  end
end
