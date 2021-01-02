require "../card_back"

module Cards::CardBacks
  class Bordered < CardBack
    BORDER = 5

    def draw_design(screen_x, screen_y, width, height)
      # colored border
      Game::RoundedRectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        roundness: 0.15_f32,
        color: color
      ).draw

      # inner fill
      Game::RoundedRectangle.new(
        x: screen_x + BORDER * 2,
        y: screen_y + BORDER * 2,
        width: width - BORDER * 4,
        height: height - BORDER * 4,
        roundness: 0.15_f32,
        color: alt_color
      ).draw
    end
  end
end
