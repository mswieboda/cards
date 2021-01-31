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

      @menu = MainMenu.new(%w(blackjack solitare options exit))
      @game = Blackjack::GameMode.new

      @menu.on("blackjack") do
        @game = Blackjack::GameMode.new
      end

      @menu.on("solitare") do
        @game = Solitare::GameMode.new
      end

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
        :chip_accent => {
          filename: "../assets/chip_accent.png",
          width: 32,
          height: 16,
          loops: false
        },
        :chip_color => {
          filename: "../assets/chip_color.png",
          width: 32,
          height: 16,
          loops: false
        },
        :chip_highlight => {
          filename: "../assets/chip_highlight.png",
          width: 38,
          height: 22,
          loops: false
        }
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
