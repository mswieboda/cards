require "./seat_player"

module Cards
  class Player < SeatPlayer
    @bet_ui : BetUI
    @chips : Array(Chip)

    def initialize(name = "", seat = Seat.new, balance = 0)
      super

      @bet_ui = BetUI.new
      @chips = [] of Chip
    end

    def new_hand
      super

      @chip_stack.chips.clear
    end

    def update(frame_time)
      return unless super

      if playing?
        if Game::Key::Space.pressed?
          stand
        elsif Game::Key::Enter.pressed?
          hit
        end
      elsif !confirmed_bet?
        @bet_ui.update(frame_time)
        @chips.each(&.update(frame_time))

        if chip = @bet_ui.chip
          if place_bet(chip.value)
            @placing_bet = true
            chip.move(@chip_stack.add_chip_position)
            @chips << chip
          end
        end

        @chips.select(&.moved?).each do |chip|
          @chips.delete(chip)
          @chip_stack.add(chip)
        end

        @placing_bet = false if @chips.empty?

        confirm_bet if Game::Keys.pressed?([Game::Key::Space, Game::Key::LShift, Game::Key::RShift, Game::Key::Enter])
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      super

      @bet_ui.draw(screen_x, screen_y)
      @chips.each(&.draw(screen_x, screen_y))
    end
  end
end
