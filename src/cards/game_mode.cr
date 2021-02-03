module Cards
  abstract class GameMode
    getter? exit
    getter? game_over

    def initialize
      @exit = false
      @game_over = false
    end

    def update(frame_time)
      exit if Game::Key::Escape.pressed?
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

    def exit
      @exit = true
    end
  end
end
