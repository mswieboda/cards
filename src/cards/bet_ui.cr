module Cards
  class BetUI
    getter position : Game::Vector
    property chip : Chip | Nil

    delegate :x, :y, to: position

    @bet_chips : Array(BetChip)

    def initialize
      @position = Game::Vector.new(
        x: Main.screen_width / 2_f32,
        y: Main.screen_height - Chip.height - CardSpot.margin / 2_f32
      )

      @bet_chips = BetChip.values
      @bet_chips.each_with_index do |chip, index|
        start_x = x - @bet_chips.size / 2_f32 * (Chip.width + CardSpot.margin) + CardSpot.margin / 2_f32
        chip.position.x = start_x + index * (Chip.width + CardSpot.margin)
        chip.position.y = y
      end

      @chip = nil
    end

    def update(frame_time)
      @bet_chips.each(&.update(frame_time))

      if bet_chip = @bet_chips.find(&.selected?)
        @chip = bet_chip.to_chip
      elsif @chip
        @chip = nil
      end
    end

    def draw(screen_x, screen_y)
      @bet_chips.each(&.draw(screen_x, screen_y))
    end
  end
end
