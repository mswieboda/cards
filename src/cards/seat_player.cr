module Cards
  abstract class SeatPlayer < CardPlayer
    getter balance : Int32 | Float32
    getter bet : Int32 | Float32
    getter? placed_bet
    getter? leave_table

    def initialize(@balance = 0, card_spots = [] of CardSpot)
      super(card_spots: card_spots)

      @bet = 0
      @placed_bet = false
      @leave_table = false
    end

    def new_hand
      super

      @placed_bet = false
    end

    def place_bet(bet = 1)
      puts ">>> #{self.class}#place_bet balance: #{balance} bet: #{bet}" if Main::DEBUG

      @bet = bet

      if @balance - @bet >= 0
        @balance -= @bet
        puts ">>> #{self.class}#place_bet placed bet: #{bet} new balance: #{balance}" if Main::DEBUG
        @placed_bet = true
      else
        # message to decrease bet, or buy in to increase balance
        puts ">>> #{self.class}#place_bet not enough chips, balance: #{@balance} bet: #{@bet}" if Main::DEBUG
      end
    end

    def done(dealer : Dealer)
      super

      if Main::DEBUG
        puts "player: #{hand_display} #{cards.map(&.short_name)}"
        puts "dealer: #{dealer.hand_display} #{dealer.cards.map(&.short_name)}"
      end

      # determine winnings/losings
      if bust?
        puts ">>> #{self.class}#done player bust: lose" if Main::DEBUG
        lose
      elsif dealer.bust?
        puts ">>> #{self.class}#done dealer bust: win" if Main::DEBUG
        win
      else
        if blackjack?
          if dealer.blackjack?
            puts ">>> #{self.class}#done player and dealer blackjack: push" if Main::DEBUG
            push
          else
            puts ">>> #{self.class}#done player blackjack: win" if Main::DEBUG
            win(Blackjack.blackjack_payout_ratio)
          end
        else
          if hand_value > dealer.hand_value
            puts ">>> #{self.class}#done player has more: win" if Main::DEBUG
            win
          elsif hand_value < dealer.hand_value
            puts ">>> #{self.class}#done player has less: lose" if Main::DEBUG
            lose
          else
            if dealer.blackjack?
              puts ">>> #{self.class}#done same value, dealer blackjack: lose" if Main::DEBUG
              lose
            else
              puts ">>> #{self.class}#done same value, push: lose" if Main::DEBUG
              push
            end
          end
        end
      end
    end

    def win(payout_ratio = 1)
      payout = payout_ratio * bet + bet
      puts ">>> #{self.class}#win #{payout}"

      # add to balance
      @balance += payout
    end

    def lose
      # don't do anything, bet was already taken out of balance
      puts ">>> #{self.class}#lose (#{bet})"
    end

    def push
      payout = bet
      puts ">>> #{self.class}#push #{payout}"

      @balance += payout
    end

    def leave_table
      @leave_table = true
    end
  end
end
