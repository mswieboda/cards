module Cards
  abstract class SeatPlayer < CardPlayer
    getter name : String
    getter balance : Int32 | Float32
    getter bet : Int32 | Float32
    getter? placed_bet
    getter? leave_table

    def initialize(@name = "", seat = Seat.new, @balance = 0)
      super(seat: seat)

      @bet = 0
      @placed_bet = false
      @leave_table = false
    end

    def draw(screen_x = 0, screen_y = 0)
      super

      last_y = draw_name(screen_x, screen_y)
      last_y = draw_balance(screen_x, screen_y, last_y)
      draw_chips(screen_x, screen_y, last_y)
    end

    def draw_name(screen_x = 0, screen_y = 0)
      mid_x = seat.x
      y = seat.y

      text = Game::Text.new(
        text: name,
        x: (screen_x + mid_x).to_i,
        y: (screen_y + y).to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y += (CardSpot.margin + CardSpot.height).to_i

      text.draw

      text.y + text.height
    end

    def draw_balance(screen_x = 0, screen_y = 0, y = 0)
      mid_x = seat.x

      text = Game::Text.new(
        text: "balance: #{balance}",
        x: (screen_x + mid_x).to_i,
        y: y.to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y += (CardSpot.margin / 2_f32).to_i

      text.draw

      text.y + text.height
    end

    def draw_chips(screen_x = 0, screen_y = 0, y = 0)
      mid_x = seat.x

      text = Game::Text.new(
        text: "bet: #{bet}",
        x: (screen_x + mid_x).to_i,
        y: y.to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y += (CardSpot.margin / 2_f32).to_i

      text.draw

      # drawing chips testing
      # how many chips are we drawing?
      chips = 3

      y = (text.y + text.height).to_i

      chips.times do |n|
        # draw the bottom one (farthest in y) first
        chip = Chip.new
        chip.position.x = text.x.to_i
        chip.position.y = y + (chips - n) * Chip.height_depth
        chip.draw(screen_x, screen_y)
      end

      text.y + text.height
    end

    def new_hand
      super

      @placed_bet = false
    end

    def log_name
      "#{name} #{super}"
    end

    def place_bet(bet = 1)
      log(:place_bet, "balance: #{balance} bet: #{bet}")

      @bet = bet

      if @balance - @bet >= 0
        @balance -= @bet
        log(:place_bet, "placed bet: #{bet} new balance: #{balance}")
        @placed_bet = true
      else
        # message to decrease bet, or buy in to increase balance
        log(:place_bet, "not enough chips, balance: #{@balance} bet: #{@bet}")
      end
    end

    def done(dealer : Dealer)
      super

      log(:done, "player: #{hand_display} #{cards.map(&.short_name)}")
      log(:done, "dealer: #{dealer.hand_display} #{dealer.cards.map(&.short_name)}")

      # determine winnings/losings
      if bust?
        log(:done, "player bust: lose")
        lose
      elsif dealer.bust?
        log(:done, "dealer bust: win")
        win
      else
        if blackjack?
          if dealer.blackjack?
            log(:done, "player and dealer blackjack: push")
            push
          else
            log(:done, "player blackjack: win")
            win(Blackjack.blackjack_payout_ratio)
          end
        else
          if hand_value > dealer.hand_value
            log(:done, "player has more: win")
            win
          elsif hand_value < dealer.hand_value
            log(:done, "player has less: lose")
            lose
          else
            if dealer.blackjack?
              log(:done, "same value, dealer blackjack: lose")
              lose
            else
              log(:done, "same value, push: lose")
              push
            end
          end
        end
      end
    end

    def win(payout_ratio = 1)
      payout = payout_ratio * bet + bet
      log(:win, "#{payout}")
      @message = "win"

      # add to balance
      @balance += payout
    end

    def lose
      # don't do anything, bet was already taken out of balance
      log(:lose, "(#{bet})")
      @message = "lose"
    end

    def push
      payout = bet
      log(:push, "#{payout}")
      @message = "push"

      @balance += payout
    end

    def leave_table
      @leave_table = true
    end
  end
end
