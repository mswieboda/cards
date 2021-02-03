module Cards
  module Blackjack
    class GameMode < Cards::GameMode
      @manager : Manager

      BLACKJACK_PAYOUT_RATIO = 1.5_f32 # 3/2
      SIDE_MARGIN = Card.width * 2

      def initialize
        super

        deck = StandardDeck.new(jokers: false)

        seats = [] of Seat
        seats << Seat.new(
          x: Main.screen_width - SIDE_MARGIN - Card.width - Card.margin,
          y: Main.screen_height / 2_f32
        )
        mid_seat = Seat.new(
          x: Main.screen_width / 2_f32,
          y: Main.screen_height / 2_f32
        )
        seats << mid_seat
        seats << Seat.new(
          x: SIDE_MARGIN + Card.width + Card.margin,
          y: Main.screen_height / 2_f32
        )

        seat_players = [] of SeatPlayer

        player = Player.new(name: "Matt", seat: mid_seat, balance: 300)
        mid_seat.player = player
        seat_players << player

        seat_players << CpuPlayer.new(name: "Tyler", balance: 300)
        seat_players << CpuPlayer.new(name: "Jack", balance: 300)

        @manager = Manager.new(seats: seats, deck: deck, seat_players: seat_players)
      end

      def update(frame_time)
        super

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
end
