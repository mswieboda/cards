module Cards
  class Main < Game::Game
    DEBUG = false
    TARGET_FPS = 60

    @game : GameMode

    def initialize
      super(
        name: "cards",
        screen_width: 1024,
        screen_height: 640,
        target_fps: TARGET_FPS,
        audio: false,
        debug: DEBUG,
        draw_fps: DEBUG
      )

      @menu = MainMenu.new
      @game = Blackjack.new

      @menu.show
    end

    def update(frame_time)
      if @menu.shown?
        @menu.update(frame_time)

        if @menu.done?
          @menu.hide
        end

        return
      end

      if @game.game_over?
        @menu.show
      end
    end

    def draw
      if @menu.shown?
        @menu.draw
        return
      end

      @game.draw
    end

    def close?
      @menu.exit? || @game.exit?
    end
  end
end
