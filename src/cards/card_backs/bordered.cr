require "../card_back"

module Cards::CardBacks
  class Bordered < CardBack
    BORDER = 10

    def draw(screen_x, screen_y, width, height)
      # outer border
      Game::Rectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        color: color
      ).draw

      # inner fill
      Game::Rectangle.new(
        x: screen_x + BORDER,
        y: screen_y + BORDER,
        width: width - BORDER * 2,
        height: height - BORDER * 2,
        color: alt_color
      ).draw
    end
  end
end
