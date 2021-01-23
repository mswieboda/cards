module Cards
  abstract class SeatPlayer < CardPlayer
    getter name : String
    getter balance : Int32 | Float32
    getter bet : Int32 | Float32
    getter? placing_bet
    getter? confirmed_bet
    getter? settled_bet
    getter? leave_table

    @payout : Int32 | Float32
    @paid_out : Int32 | Float32
    @chip_stack_bet : ChipStack
    @chip_stack_winnings : ChipStack
    @chips : Array(Chip)
    @result : Result

    CHIP_DELAY = 0.13_f32

    enum Result
      Lose
      Win
      Push
    end

    def initialize(@name = "", seat = Seat.new, @balance = 0)
      @bet = 0
      @payout = 0
      @paid_out = 0
      @result = Result::Push
      @placing_bet = false
      @confirmed_bet = false
      @settled_bet = false
      @leave_table = false

      @chip_stack_bet = ChipStack.new
      @chip_stack_winnings = ChipStack.new

      @chips = [] of Chip

      super(
        seat: seat,
        chip_tray: ChipTray.new(
          y: Main.screen_height - CardSpot.margin - Chip.height,
          balance: @balance
        )
      )
    end

    def update_positions
      super

      @chip_stack_bet.x = @seat.x - Chip.width / 2_f32
      @chip_stack_bet.y = @seat.y + CardSpot.height + CardSpot.margin
      @chip_stack_winnings.x = @seat.x - Chip.width / 2_f32 - CardSpot.margin - Chip.width
      @chip_stack_winnings.y = @seat.y + CardSpot.height + CardSpot.margin
    end

    def update(frame_time)
      super

      @chips.each(&.update(frame_time))

      return if delay?

      if playing?
        playing_update(frame_time)
      elsif placing_bet? || !confirmed_bet?
        betting_update(frame_time)
      end
    end

    def playing_update(_frame_time)
    end

    def betting_update(frame_time)
      @chips.select(&.moved?).each do |chip|
        @chips.delete(chip)
        @chip_stack_bet.add(chip)
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      super

      @chips.select { |c| c.y <= @chip_stack_bet.top_y }.each(&.draw(screen_x, screen_y))

      last_y = draw_chips(screen_x, screen_y)
      last_y = draw_name(screen_x, screen_y, last_y)
      last_y = draw_balance(screen_x, screen_y, last_y)

      @chips.select { |c| c.y > @chip_stack_bet.top_y }.each(&.draw(screen_x, screen_y))
    end

    def draw_chips(screen_x = 0, screen_y = 0)
      mid_x = seat.x

      @chip_stack_bet.draw(screen_x, screen_y)
      @chip_stack_winnings.draw(screen_x, screen_y)

      y = @chip_stack_bet.y + Chip.height + (CardSpot.margin / 2_f32).to_i

      text = Game::Text.new(
        text: "bet: #{bet}",
        x: (screen_x + mid_x).to_i,
        y: (screen_y + y).to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i

      text.draw

      text.y + text.height
    end

    def draw_name(screen_x = 0, screen_y = 0, y = 0)
      mid_x = seat.x

      text = Game::Text.new(
        text: name,
        x: (screen_x + mid_x).to_i,
        y: (screen_y + y).to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y += (CardSpot.margin / 2_f32).to_i

      text.draw

      text.y + text.height
    end

    def draw_balance(screen_x = 0, screen_y = 0, y = 0)
      mid_x = seat.x

      text = Game::Text.new(
        text: "balance: #{balance}",
        x: (screen_x + mid_x).to_i,
        y: (screen_y + y).to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y += (CardSpot.margin / 2_f32).to_i

      text.draw

      text.y + text.height
    end

    def new_hand
      super

      @placing_bet = false
      @confirmed_bet = false
      @settled_bet = false
      @bet = 0
      @payout = 0
      @paid_out = 0
      @result = Result::Push
    end

    def log_name
      "#{name} #{super}"
    end

    def place_bet(bet = 1) : Bool
      if balance - bet >= 0
        @bet += bet
        @balance -= bet
        log(:place_bet, "placed bet: #{bet} new balance: #{balance}")
        true
      else
        # message to decrease bet, or buy in to increase balance
        log(:place_bet, "not enough chips, balance: #{balance} bet: #{bet}")
        false
      end
    end

    def confirm_bet
      if bet > 0 && balance >= 0
        log(:confirm_bet, "confirmed bet: #{bet} balance: #{balance}")
        @confirmed_bet = true
      else
        # message to decrease bet, or buy in to increase balance
        log(:confirm_bet, "not enough chips, balance: #{balance} bet: #{bet}")
      end
    end

    def done(dealer : Dealer)
      super

      log(:done, "player: #{hand_display} #{cards.map(&.short_name)}")
      log(:done, "dealer: #{dealer.hand_display} #{dealer.cards.map(&.short_name)}")

      # determine winnings/losings
      if bust?
        log(:done, "player bust: lose")
        lose(dealer)
      elsif dealer.bust?
        log(:done, "dealer bust: win")
        win(dealer)
      else
        if blackjack?
          if dealer.blackjack?
            log(:done, "player and dealer blackjack: push")
            push(dealer)
          else
            log(:done, "player blackjack: win")
            win(dealer, Blackjack.blackjack_payout_ratio)
          end
        else
          if hand_value > dealer.hand_value
            log(:done, "player has more: win")
            win(dealer)
          elsif hand_value < dealer.hand_value
            log(:done, "player has less: lose")
            lose(dealer)
          else
            if dealer.blackjack?
              log(:done, "same value, dealer blackjack: lose")
              lose(dealer)
            else
              log(:done, "same value, push: lose")
              push(dealer)
            end
          end
        end
      end
    end

    def win(dealer : Dealer, payout_ratio : Int32 | Float32 = 1)
      @payout = payout_ratio * bet
      log(:win, "#{@payout}")
      @result = Result::Win
      @message = @result.to_s.downcase

      # add to balance
      @balance += @payout + bet
    end

    def lose(dealer : Dealer)
      # don't do anything, bet was already taken out of balance
      log(:lose, "(#{bet})")
      @result = Result::Lose
      @message = @result.to_s.downcase
    end

    def push(dealer : Dealer)
      log(:push)
      @result = Result::Push
      @message = @result.to_s.downcase

      @balance += bet
    end

    def leave_table
      log(:leave_table)
      @leave_table = true
    end

    def chip_delay
      CHIP_DELAY
    end

    def cleared_table?
      super && cleared_chips?
    end

    def cleared_chips?
      @chip_stack_winnings.empty? && @chip_stack_bet.empty? && @chips.empty?
    end

    def paid?
      @paid_out == @chip_stack_winnings.chip_value && (
        @paid_out == @payout ||
        # in case payout is greater than the lowest chip amount (Amount::One value of 1)
        # such as winnings = 50, payout = 50.25
        @paid_out + Chip::Amount.values.first.value > @payout
      )
    end

    def pay_player_chip(dealer)
      if chip = Chip.largest(@payout - @paid_out)
        @paid_out += chip.value

        pay_chip(chip: chip, dealer: dealer, from_dealer: true)
      end
    end

    def pay_dealer_chip(dealer)
      chip = @chip_stack_bet.take

      pay_chip(chip: chip, dealer: dealer)
    end

    def pay_chip(chip : Chip, dealer : Dealer, from_dealer = false)
      if position = dealer.chip_tray.add_position(chip)
        chip.position = position if from_dealer
        @chips << chip
        chip.move(from_dealer ? @chip_stack_winnings.add_chip_position : position)
        delay(chip_delay)
      end
    end

    def settle_bet(dealer : Dealer)
      log(:settle_bet)

      @chips.select(&.moved?).each do |chip|
        @chips.delete(chip)

        if @result.win? || @result.push?
          @chip_stack_winnings.add(chip)
        else
          dealer.chip_tray.add(chip)
        end
      end

      if @result.win? || @result.push?
        pay_player_chip(dealer) unless paid?

        if paid? && @chips.empty?
          @settled_bet = true
          delay(done_delay)
        end
      else
        if @chip_stack_bet.empty?
          if @chips.empty?
            @settled_bet = true
            delay(action_delay)
          end
        else
          pay_dealer_chip(dealer)
        end
      end
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
      log(:clear_table)

      if cleared_chips?
        super
      else
        clear_chip(@chip_stack_winnings)
        clear_chip(@chip_stack_bet)

        @chips.select(&.moved?).each do |chip|
          @chips.delete(chip)
          chip_tray.add(chip)
        end
      end
    end
  end
end
