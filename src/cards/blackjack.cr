require "./game_mode"

module Cards
  class Blackjack < GameMode
    MARGIN = 10

    @dealer_card_spots : Array(CardSpot)
    @player_card_spots : Array(CardSpot)

    DEALER_CARD_SPOT_Y_RATIO = 8_f32

    def initialize
      super

      @deck = StandardDeck.new(jokers: false)

      @dealer_card_spots = [] of CardSpot
      @player_card_spots = [] of CardSpot

      # dealer spots
      @dealer_card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 - CardSpot.width - MARGIN / 2_f32,
        y: Main.screen_height / DEALER_CARD_SPOT_Y_RATIO - CardSpot.height / 2_f32
      )

      @dealer_card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 + MARGIN / 2_f32,
        y: Main.screen_height / DEALER_CARD_SPOT_Y_RATIO - CardSpot.height / 2_f32
      )

      # player spots
      @player_card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 - CardSpot.width - MARGIN / 2_f32,
        y: Main.screen_height / 2_f32 - CardSpot.height / 2_f32
      )

      @player_card_spots << CardSpot.new(
        x: Main.screen_width / 2_f32 + MARGIN / 2_f32,
        y: Main.screen_height / 2_f32 - CardSpot.height / 2_f32
      )
    end

    def update(frame_time)
      @deck.update(frame_time)
    end

    def draw
      super

      @dealer_card_spots.each(&.draw)
      @player_card_spots.each(&.draw)
      @deck.draw
    end
  end
end
