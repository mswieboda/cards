module Cards
  abstract class GameMode
    getter? exit
    getter? game_over

    def initialize
      @exit = false
      @game_over = false
    end

    def update(frame_time)

    end

    def draw
      Game::Rectangle.new(
        x: 0,
        y: 0,
        width: Main.screen_width,
        height: Main.screen_height,
        color: Game::Color::Green
      ).draw
    end
  end
end
