module Cards
  abstract class SeatPlayer < CardPlayer
    getter name : String
    getter balance : Int32 | Float32
    getter bet : Int32 | Float32
    getter? placing_bet
    getter? confirmed_bet
    getter? leave_table

    @payout : Int32 | Float32
    @chip_stack_bet : ChipStack
    @chip_stack_winnings : ChipStack
    @chips : Array(Chip)
    @result : Result

    enum Result
      Lose
      Win
      Push
    end

    def initialize(@name = "", seat = Seat.new, @balance = 0)
      super(seat: seat)

      @bet = 0
      @payout = 0
      @result = Result::Push
      @placing_bet = false
      @confirmed_bet = false
      @leave_table = false

      @chip_stack_bet = ChipStack.new(
        x: seat.x - Chip.width / 2_f32,
        y: seat.y + CardSpot.height + CardSpot.margin
      )
      @chip_stack_winnings = ChipStack.new(
        x: seat.x - Chip.width / 2_f32 - CardSpot.margin - Chip.width,
        y: seat.y + CardSpot.height + CardSpot.margin
      )

      @chips = [] of Chip
    end

    def seat=(seat : Seat)
      @seat = seat
      @chip_stack_bet.x = @seat.x - Chip.width / 2_f32
      @chip_stack_bet.y = @seat.y + CardSpot.height + CardSpot.margin
      @seat
    end

    def update(frame_time)
      super

      @chips.each(&.update(frame_time))

      return if delay?

      if playing?
        playing_update(frame_time)
      elsif !confirmed_bet?
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

      @chips.each(&.draw(screen_x, screen_y))

      last_y = draw_chips(screen_x, screen_y)
      last_y = draw_name(screen_x, screen_y, last_y)
      last_y = draw_balance(screen_x, screen_y, last_y)
    end

    def draw_chips(screen_x = 0, screen_y = 0)
      mid_x = seat.x

      @chip_stack_bet.draw(screen_x, screen_y)

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

      @confirmed_bet = false
      @placing_bet = false
      @bet = 0
      @payout = 0
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

    def cleared_table?
      super && cleared_chips?
    end

    def cleared_chips?
      @chip_stack_winnings.empty? && @chip_stack_bet.empty?
    end

    def paid_out?
      @chips.none?(&.moving?) && (
        @chip_stack_winnings.chip_value == @payout ||
        # in case payout is greater than the lowest chip amount (Amount::One value of 1)
        # such as winnings = 50, payout = 50.25
        @chip_stack_winnings.chip_value + Chip::Amount.values.first.value > @payout
      )
    end

    def payout_chip(dealer)
      # create largest chip, move chip to player @chip_stack_winnings
      if chip = Chip.largest(@payout)
        @payout -= chip.value

        if chip_tray = dealer.chip_trays.find { |chip_tray| chip_tray.amount == chip.amount }
          chip.position = chip_tray.position.copy
          @chips << chip
          chip.move(@chip_stack_winnings.add_chip_position)
        end
      end
    end

    def clearing_table(_discard_stack : CardStack, dealer : Dealer)
      log(:clearing_table)

      if cleared_chips?
        super
      else
        if @result.win?
          @chips.select(&.moved?).each do |chip|
            @chips.delete(chip)
            @chip_stack_bet.add(chip)
          end

          if @chips.none?(&.moving?)
            if paid_out?
              # TODO:
              # TODO:
              # TODO:
              # move chip to player, one from winnings, one from bet
              @chip_stack_bet.chips.clear
              @chip_stack_winnings.chips.clear
              # TODO:
              # TODO:
              # TODO:

            else
              payout_chip(dealer)
            end
          end
        else
          @chips.select(&.moved?).each do |chip|
            @chips.delete(chip)
          end

          # move chip to dealer from bet
          chip = @chip_stack_bet.take

          if chip_tray = dealer.chip_trays.find { |chip_tray| chip_tray.amount == chip.amount }
            @chips << chip
            chip.move(chip_tray.position)
          end
        end
      end
    end
  end
end
