require "../card_back"

module Cards::CardBacks
  class Diagonal < CardBack
    def draw_design(screen_x, screen_y, width, height)
      Game::RoundedRectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        roundness: 0.15_f32,
        color: alt_color
      ).draw
    end
  end
end
