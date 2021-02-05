require "json"

module Cards
  abstract class GameMode
    include JSON::Serializable

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

    def exit?
      Key.exit.pressed?
    end
  end
end
