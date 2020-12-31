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

      load_sprites

      @menu = MainMenu.new
      @game = Blackjack.new

      @menu.show
    end

    def load_sprites
      Game::Sprite.load({
        :diamonds => {
          filename: "../assets/diamonds.png",
          width: 64,
          height: 64,
          loops: false,
        },
        :clubs => {
          filename: "../assets/clubs.png",
          width: 64,
          height: 64,
          loops: false,
        },
        :hearts => {
          filename: "../assets/hearts.png",
          width: 64,
          height: 64,
          loops: false,
        },
        :spades => {
          filename: "../assets/spades.png",
          width: 64,
          height: 64,
          loops: false,
        },
      })
    end

    def update(frame_time)
      if @menu.shown?
        @menu.update(frame_time)

        if @menu.done?
          @menu.hide
        end

        return
      end

      @game.update(frame_time)

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
