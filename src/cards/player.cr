require "./seat_player"

module Cards
  class Player < SeatPlayer
    @bet_ui : BetUI

    def initialize(name = "", seat = Seat.new, balance = 0)
      super

      @bet_ui = BetUI.new
    end


    def update(frame_time)
      return unless super

      if playing?
        if Game::Key::Space.pressed?
          stand
        elsif Game::Key::Enter.pressed?
          hit
        end
      else
        if Game::Keys.pressed?([Game::Key::Space, Game::Key::LShift, Game::Key::RShift, Game::Key::Enter])
          # TODO: impl chips, player bet changing, for now bet 1
          place_bet
        end
      end

      @bet_ui.update(frame_time)
    end

    def draw(screen_x = 0, screen_y = 0)
      super

      @bet_ui.draw(screen_x, screen_y)
    end
  end
end
