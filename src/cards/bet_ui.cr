module Cards
  class BetUI
    getter position : Game::Vector

    delegate :x, :y, to: position

    @chips : Array(BetChip)

    def initialize
      @position = Game::Vector.new(
        x: Main.screen_width / 2_f32,
        y: Main.screen_height - Chip.height - CardSpot.margin / 2_f32
      )

      @chips = BetChip.values
      @chips.each_with_index do |chip, index|
        start_x = x - @chips.size / 2_f32 * (Chip.width + CardSpot.margin)
        chip.position.x = start_x + index * (Chip.width + CardSpot.margin)
        chip.position.y = y
      end
    end

    def update(frame_time)
      @chips.each(&.update(frame_time))
    end

    def draw(screen_x, screen_y)
      @chips.each(&.draw(screen_x, screen_y))
    end
  end
end
