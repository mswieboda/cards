module Cards::CardBacks
  class Diagonal < CardBack
    SPACING = 10

    def draw(screen_x, screen_y, width, height)
      # inner fill
      Game::Rectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        color: alt_color
      ).draw
    end
  end
end
