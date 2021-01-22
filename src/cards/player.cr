require "./seat_player"

module Cards
  class Player < SeatPlayer
    @bet_trays : Array(BetTray)

    def initialize(name = "", seat = Seat.new, balance = 0)
      @bet_trays = [] of BetTray
      chip_trays = [] of ChipTray

      Chip::Amount.values.each do |amount|
        bet_tray = BetTray.new(amount: amount)
        chip_trays << bet_tray
        @bet_trays << bet_tray
      end

      super(
        name: name,
        seat: seat,
        balance: balance,
        chip_trays: chip_trays
      )
    end

    def playing_update(_frame_time)
      if Game::Key::Space.pressed?
        stand
      elsif Game::Key::Enter.pressed?
        hit
      end
    end

    def betting_update(frame_time)
      super

      @chip_trays.each(&.update(frame_time))

      if bet_tray = @bet_trays.find(&.selected?)
        chip = bet_tray.to_chip

        if place_bet(chip.value)
          @placing_bet = true
          chip.move(@chip_stack_bet.add_chip_position)
          @chips << chip
        end
      end

      @placing_bet = false if @chips.empty?

      confirm_bet if Game::Keys.pressed?([Game::Key::Space, Game::Key::LShift, Game::Key::RShift, Game::Key::Enter])
    end
  end
end
