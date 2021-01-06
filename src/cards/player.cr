require "./seat_player"

module Cards
  class Player < SeatPlayer
    def initialize(balance = 0, @card_spots = [] of CardSpot)
      if card_spots.empty?
        card_spots << CardSpot.new(
          x: Main.screen_width / 2_f32 - CardSpot.width - CardSpot.margin / 2_f32,
          y: Main.screen_height / 2_f32 - CardSpot.height / 2_f32
        )
        card_spots << CardSpot.new(
          x: Main.screen_width / 2_f32 + CardSpot.margin / 2_f32,
          y: Main.screen_height / 2_f32 - CardSpot.height / 2_f32
        )
      end

      super(balance: balance, card_spots: card_spots)
    end

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
