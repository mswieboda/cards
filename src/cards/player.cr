require "./seat_player"

module Cards
  class Player < SeatPlayer
    def update(_frame_time)
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
    end
  end
end
