require "./game_mode"

module Cards
  class Blackjack < GameMode
    @manager : Manager

    def initialize
      super

      deck = StandardDeck.new(jokers: false)

      seat_players = [] of SeatPlayer
      seat_players << Player.new

      @manager = Manager.new(deck: deck, seat_players: seat_players)
    end

    def update(frame_time)
      @manager.update(frame_time)
    end

    def draw
      super

      @manager.draw
    end
  end
end
