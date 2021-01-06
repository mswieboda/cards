require "./game_mode"

module Cards
  class Blackjack < GameMode
    @manager : Manager

    BLACKJACK_PAYOUT_RATIO = 1.5_f32 # 3/2

    def initialize
      super

      deck = StandardDeck.new(jokers: false)

      seat_players = [] of SeatPlayer
      seat_players << Player.new(balance: 300)

      @manager = Manager.new(deck: deck, seat_players: seat_players)
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
