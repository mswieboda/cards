module Cards
  abstract class SeatPlayer < CardPlayer
    getter name : String
    getter? leave_table
    getter? placing_bet
    getter? clearing_bet

    @chips : Array(Chip)

    CHIP_DELAY = 0.13_f32

    def initialize(@name = "", seat = Seat.new, balance = 0)
      @chips = [] of Chip
      @leave_table = false
      @placing_bet = false
      @clearing_bet = false

      super(
        seat: seat,
        chip_tray: ChipTray.new(
          y: Main.screen_height - Card.margin - Chip.height,
          balance: balance
        )
      )
    end

    def update(frame_time)
      super

      @chips.each(&.update(frame_time))

      if !delay? && playing?
        playing_update(frame_time)
      elsif !confirmed_bet?
        betting_update(frame_time)
      end
    end

    def move_chips
      @chips.select(&.moved?).each do |chip|
        @chips.delete(chip)

        if placing_bet?
          if hand = current_hand
            hand.chip_stack_bet.add(chip)
          end
        else
          @chip_tray.add(chip)
        end
      end
    end

    def playing_update(_frame_time)
      move_chips
      # double_bet if doubling_bet?
    end

    def betting_update(frame_time)
      move_chips
      clear_bet if clearing_bet?

      @placing_bet = false if @chips.empty?

      chip_tray.update(frame_time)
    end

    def balance
      @chip_tray.chip_value
    end

    def draw(screen_x = 0, screen_y = 0)
      chip_tray.draw(screen_x, screen_y)

      # @chips.select { |c| c.y <= @chip_stack_bet.top_y }.each(&.draw(screen_x, screen_y))

      draw_hands(screen_x, screen_y)

      draw_name(screen_x, screen_y)

      # @chips.select { |c| c.y > @chip_stack_bet.top_y }.each(&.draw(screen_x, screen_y))
      @chips.each(&.draw(screen_x, screen_y))
    end

    def draw_bets?
      true
    end

    def draw_name(screen_x = 0, screen_y = 0)
      mid_x = seat.x

      y = Main.screen_height

      text = Game::Text.new(
        text: name,
        x: (screen_x + mid_x).to_i,
        y: (screen_y + y).to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y -= text.height + (Card.margin / 2_f32).to_i

      text.draw

      text.y + text.height
    end

    def log_name
      "#{name} #{super}"
    end

    def place_bet(chip : Chip)
      log(:place_bet, "placed bet: #{chip.value} new balance: #{balance}")

      if hand = current_hand
        @placing_bet = true

        chip.move(hand.chip_stack_bet.add_chip_position)
        @chips << chip
      end
    end

    def clear_bet
      if hand = current_hand
        if hand.chip_stack_bet.empty? && @chips.empty?
          @clearing_bet = false
          return
        end

        clear_chip(hand.chip_stack_bet) unless delay?
      end
    end

    # def can_double_bet?
    #   balance >= bet
    # end

    # def double_down
    #   log(:double_down)
    #   @doubling_bet = true
    #   @doubling_bet_left = bet
    # end

    # def double_bet
    #   log(:double_bet)
    #   if chip = chip_tray.largest(@doubling_bet_left)
    #     place_bet(chip)
    #     @doubling_bet_left -= chip.value if doubling_bet?
    #   end

    #   if @doubling_bet_left == 0 && @chips.empty?
    #     if placing_bet?
    #       @placing_bet = false
    #       delay(deal_delay)
    #     elsif !hitting?
    #       @hitting = true
    #     else
    #       @doubling_bet = false
    #       hand_check
    #       play_done if playing?
    #     end
    #   end
    # end

    def confirmed_bet?
      hands.all?(&.confirmed_bet?)
    end

    def confirm_bet
      if hand = current_hand
        if hand.bet > 0 && balance >= 0
          log(:confirm_bet, "confirmed bet: #{hand.bet} balance: #{balance}")
          hand.confirmed_bet = true
        else
          # message to decrease bet, or buy in to increase balance
          log(:confirm_bet, "not enough chips, balance: #{balance} bet: #{hand.bet}")
        end
      end
    end

    def done(dealer : Dealer)
      super
      hands.each(&.done(dealer))
    end

    def leave_table
      log(:leave_table)
      @leave_table = true
    end

    def chip_delay
      CHIP_DELAY
    end

    def paid?
      hands.all?(&.paid?)
    end

    def settled_bets?
      @chips.empty? && hands.all?(&.paid?)
    end

    def add_chip(chip : Chip)
      @chips << chip
      delay(chip_delay)
    end

    def settle_bet(dealer : Dealer)
      if hand = current_hand
        @chips.select(&.moved?).each do |chip|
          @chips.delete(chip)

          if hand.win? || hand.push?
            hand.chip_stack_winnings.add(chip)
          else
            dealer.chip_tray.add(chip)
          end
        end

        hand.settle_bet(dealer, self)

        if hand.paid? && @chips.empty?
          @hand_index += 1 if @hand_index + 1 < hands.size
          delay(done_delay)
        end
      end
    end

    def cleared_chips?
      @chips.empty? && hands.all?(&.cleared_chips?)
    end

    def clear_chip(chip_stack : ChipStack)
      return if chip_stack.empty?

      chip = chip_stack.take

      if position = chip_tray.add_position(chip)
        chip.move(position)
        @chips << chip
        delay(deal_delay)
      end
    end

    def clear_table(discard_stack : CardStack)
      if cleared_chips?
        super
      else
        hands.each do |hand|
          clear_chip(hand.chip_stack_winnings)
          clear_chip(hand.chip_stack_bet)
        end

        @chips.select(&.moved?).each do |chip|
          @chips.delete(chip)
          chip_tray.add(chip)
        end
      end
    end
  end
end
