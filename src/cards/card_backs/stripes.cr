require "../card_back"

module Cards::CardBacks
  class Stripes < CardBack
    GAP = 5
    THICKNESS = 3

    def draw_design(screen_x, screen_y, width, height)
      Game::RoundedRectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        roundness: 0.15_f32,
        color: alt_color
      ).draw

      (height / (GAP * 2 + THICKNESS * 2) - 1).to_i.times do |n|
        next if n.zero?

        start_x = screen_x - 1
        start_y = screen_y + GAP * 2 * n + THICKNESS * 2 * n
        end_x = screen_x + GAP * 2 * n + THICKNESS * 2 * n
        end_y = screen_y - 1

        Game::Line.new(
          start_x: start_x,
          start_y: start_y,
          end_x: end_x,
          end_y: end_y,
          thickness: THICKNESS,
          color: color
        ).draw
      end
    end
  end
end
