require "./game_mode"

module Cards
  class Blackjack < GameMode
    @manager : Manager

    BLACKJACK_PAYOUT_RATIO = 1.5_f32 # 3/2
    SIDE_MARGIN = CardSpot.width * 2

    def initialize
      super

      deck = StandardDeck.new(jokers: false)

      seats = [] of Seat
      seats << Seat.new(
        x: SIDE_MARGIN + CardSpot.width + CardSpot.margin,
        y: Main.screen_height / 2_f32
      )
      seats << Seat.new(
        x: Main.screen_width / 2_f32,
        y: Main.screen_height / 2_f32
      )
      seats << Seat.new(
        x: Main.screen_width - SIDE_MARGIN - CardSpot.width - CardSpot.margin,
        y: Main.screen_height / 2_f32
      )

      seat_players = [] of SeatPlayer
      seat_players << CpuPlayer.new(name: "Tyler", balance: 300)
      seat_players << Player.new(name: "Matt", seat: seats[1], balance: 300)
      seat_players << CpuPlayer.new(name: "Jack", balance: 300)

      @manager = Manager.new(seats: seats, deck: deck, seat_players: seat_players)
    end

    def update(frame_time)
      @manager.update(frame_time)
    end

    def draw
      super

      @manager.draw
    end

    def self.blackjack_payout_ratio
      BLACKJACK_PAYOUT_RATIO
    end
  end
end
