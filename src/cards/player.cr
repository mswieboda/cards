require "./seat_player"

module Cards
  class Player < SeatPlayer
    @bet_ui : BetUI

    def initialize(name = "", seat = Seat.new, balance = 0)
      super

      @bet_ui = BetUI.new
    end

    def playing_update(_frame_time)
      if Game::Key::Space.pressed?
        stand
      elsif Game::Key::Enter.pressed?
        hit
      end
    end

    def betting_update(frame_time)
      super

      @bet_ui.update(frame_time)

      if chip = @bet_ui.chip
        if place_bet(chip.value)
          @placing_bet = true
          chip.move(@chip_stack_bet.add_chip_position)
          @chips << chip
        end
      end

      @placing_bet = false if @chips.empty?

      confirm_bet if Game::Keys.pressed?([Game::Key::Space, Game::Key::LShift, Game::Key::RShift, Game::Key::Enter])
    end

    def draw(screen_x = 0, screen_y = 0)
      super

      @bet_ui.draw(screen_x, screen_y)
    end
  end
end
