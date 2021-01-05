require "./seat_player"

module Cards
  class Player < SeatPlayer
    def initialize
      card_spots = [] of CardSpot
      card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 - CardSpot.width - CardSpot.margin / 2_f32,
        y: Main.screen_height / 2_f32 - CardSpot.height / 2_f32
      )

      card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 + CardSpot.margin / 2_f32,
        y: Main.screen_height / 2_f32 - CardSpot.height / 2_f32
      )

      super(card_spots: card_spots)
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
          @placed_bet = true
        end
      end
    end
  end
end
