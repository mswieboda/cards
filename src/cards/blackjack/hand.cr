module Cards
  module Blackjack
    class Hand
      getter x : Int32 | Float32
      getter y : Int32 | Float32

      getter cards : Array(Card)

      property? playing
      getter? played
      property? hitting
      getter? bust
      getter? blackjack

      property? confirmed_bet
      property? settling_bet
      getter message : String

      getter? clearing_table

      # @log : Symbol, String, String | Nil -> Nil
      getter chip_stack_bet : ChipStack
      getter chip_stack_bet_double : ChipStack
      getter chip_stack_winnings : ChipStack

      @payout : Int32
      @paid_out : Int32
      @result : Result
      @clearing_card_index : Int32

      delegate :size, :empty?, :any?, to: cards
      delegate :win?, :lose?, :push?, to: @result

      enum Result
        Lose
        Win
        Push
      end

      def initialize(@x = 0, @y = 0, @cards = [] of Card)
        @playing = false
        @played = false
        @hitting = false
        @blackjack = false
        @bust = false

        @payout = 0
        @paid_out = 0
        @result = Result::Push
        @confirmed_bet = false
        @settling_bet = true
        @message = ""
        @clearing_table = false
        @clearing_card_index = 0

        @chip_stack_bet = ChipStack.new
        @chip_stack_bet_double = ChipStack.new
        @chip_stack_winnings = ChipStack.new

        update_positions
      end

      def x=(value : Int32 | Float32)
        @x = value
        update_positions
        @x
      end

      def y=(value : Int32 | Float32)
        @y = value
        update_positions
        @y
      end

      def update_positions
        @cards.each_with_index do |card, index|
          x = @x - Card.margin / 2_f32 - Card.width + [index, 1].min * (Card.width + Card.margin)
          x += 2 * Card.margin * (index - 1) if index >= 2

          card.x = x
          card.y = @y
        end

        @chip_stack_bet.x = x - Chip.width / 2_f32
        @chip_stack_bet.y = y + Card.height + Card.margin

        @chip_stack_bet_double.x = x - Chip.width / 2_f32 + Card.margin + Chip.width
        @chip_stack_bet_double.y = y + Card.height + Card.margin

        @chip_stack_winnings.x = x - Chip.width / 2_f32 - Card.margin - Chip.width
        @chip_stack_winnings.y = y + Card.height + Card.margin
      end

      def update(frame_time)
        @cards.each(&.update(frame_time))
      end

      def draw(screen_x, screen_y, bets = false)
        @cards.each(&.draw(screen_x, screen_y))

        last_y = draw_hand_display(screen_x, screen_y)
        draw_message(screen_x, screen_y, last_y)
        draw_bet(screen_x, screen_y) if bets
      end

      def draw_hand_display(screen_x = 0, screen_y = 0)
        hand = display
        hand = "" if hand == "0"

        text = Game::Text.new(
          text: hand,
          x: (screen_x + x).to_i,
          y: @y.to_i,
          size: 10,
          spacing: 2,
          color: Game::Color::Black,
        )

        text.x -= (text.width / 2_f32).to_i
        text.y -= (Card.margin + text.height).to_i

        text.draw

        text.y
      end

      def draw_message(screen_x = 0, screen_y = 0, y = 0)
        return if message.empty?

        text = Game::Text.new(
          text: message,
          x: (screen_x + x).to_i,
          y: y.to_i,
          size: 10,
          spacing: 2,
          color: Game::Color::Black,
        )

        text.x -= (text.width / 2_f32).to_i
        text.y -= (Card.margin + text.height).to_i

        text.draw
      end

      def draw_bet(screen_x = 0, screen_y = 0)
        @chip_stack_bet.draw(screen_x, screen_y)
        @chip_stack_bet_double.draw(screen_x, screen_y)
        @chip_stack_winnings.draw(screen_x, screen_y)

        y = @chip_stack_bet.y + Chip.height + (Card.margin / 2_f32).to_i

        text = Game::Text.new(
          text: "bet: #{bet}",
          x: (screen_x + x).to_i,
          y: (screen_y + y).to_i,
          size: 10,
          spacing: 2,
          color: Game::Color::Black,
        )

        text.x -= (text.width / 2_f32).to_i

        text.draw
      end

      # TODO: take this out, use SeatPlayer's log somehow, procs?
      def log_name
        self.class.to_s.split("::").last
      end

      # TODO: take this out, use SeatPlayer's log somehow, procs?
      def log(method, message = "")
        return unless Main::DEBUG
        puts ">>> #{log_name}##{method}#{message.presence && " > #{message}"}"
      end

      def dealing?
        @cards.any?(&.moving?)
      end

      def dealt?
        !dealing? && @cards.size >= 2
      end

      def undealt?
        !dealt?
      end

      def take : Card
        @cards.pop
      end

      def add_card_position
        x = @x - Card.margin / 2_f32 - Card.width + [cards.size, 1].min * (Card.width + Card.margin)
        x += 2 * Card.margin * (cards.size - 1) if cards.size >= 2

        position = Game::Vector.new(
          x: x,
          y: @y
        )
      end

      def deal(card_stack : CardStack, flip = true)
        log(:deal)

        card = card_stack.take

        card.flip if flip && card.flipped?

        card.move(add_card_position)
        @cards << card
        card
      end

      def check
        # return if doubling_bet?

        log(:check, "hand: #{display} cards: #{cards_short_name}")

        hand = value

        if hand > 21
          bust
        elsif hand == 21
          if value(cards[0..1]) == 21
            blackjack
          else
            twenty_one
          end
        end
      end

      def cards_short_name
        cards.map(&.short_name).join(", ")
      end

      def bet
        @chip_stack_bet.chip_value + @chip_stack_bet_double.chip_value
      end

      def done(dealer : Dealer)
        @clearing_card_index = cards.size - 1

        log(:done, "player: #{display} #{cards_short_name}")
        log(:done, "dealer: #{dealer.hand_display} #{dealer.cards_short_name}")

        # determine winnings/losings
        if bust?
          log(:done, "player bust: lose")
          lose
        elsif dealer.bust?
          if blackjack?
            log(:done, "dealer bust, player blackjack: win")
            win(GameMode.blackjack_payout_ratio)
          else
            log(:done, "dealer bust: win")
            win
          end
        else
          if blackjack?
            if dealer.blackjack?
              log(:done, "player and dealer blackjack: push")
              push
            else
              log(:done, "player blackjack: win")
              win(GameMode.blackjack_payout_ratio)
            end
          else
            if value > dealer.hand_value
              log(:done, "player has more: win")
              win
            elsif value < dealer.hand_value
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

      def win( payout_ratio : Int32 | Float32 = 1)
        @payout = (payout_ratio * bet).to_i
        log(:win, "#{@payout}")
        @result = Result::Win
        @message = @result.to_s.downcase
      end

      def lose
        log(:lose, "(#{bet})")
        @result = Result::Lose
        @message = @result.to_s.downcase
      end

      def push
        log(:push)
        @result = Result::Push
        @message = @result.to_s.downcase
      end

      def paid?
        @paid_out == @chip_stack_winnings.chip_value && @paid_out == @payout
      end

      def pay_player_chip(dealer : Dealer, player : SeatPlayer)
        if chip = dealer.chip_tray.largest(@payout - @paid_out)
          @paid_out += chip.value

          pay_chip(chip: chip, dealer: dealer, player: player, from_dealer: true)
        end
      end

      def pay_dealer_chip(dealer : Dealer, player : SeatPlayer, chip_stack : ChipStack)
        chip = chip_stack.take

        pay_chip(chip: chip, dealer: dealer, player: player)
      end

      def pay_chip(chip : Chip, dealer : Dealer, player : SeatPlayer, from_dealer = false)
        if position = dealer.chip_tray.add_position(chip)
          chip.position = position if from_dealer

          chip.move(from_dealer ? @chip_stack_winnings.add_position : position)
          player.add_chip(chip)
        end
      end

      def settled_bet?
        return unless paid?

        if lose?
          @chip_stack_bet.empty?
        elsif win?
          @chip_stack_winnings.any?
        elsif push?
          true
        end
      end

      def settle_bet(dealer : Dealer, player : SeatPlayer)
        if win?
          pay_player_chip(dealer, player) unless paid?
        elsif lose?
          pay_dealer_chip(dealer, player, @chip_stack_bet) if @chip_stack_bet.any?
          pay_dealer_chip(dealer, player, @chip_stack_bet_double) if @chip_stack_bet_double.any?
        end
      end

      def cleared_table?
        @cards.empty? && cleared_chips?
      end

      def cleared_chips?
        @chip_stack_winnings.empty? && @chip_stack_bet.empty?
      end

      def play_done
        log(:play_done)
        @hitting = false
        @playing = false
        @played = true
        # delay(done_delay)
      end

      def stand
        log(:stand)
        play_done if playing?
      end

      def hit
        log(:hit)
        @hitting = true
      end

      def bust
        log(:bust)
        @bust = true
        @message = "bust"
        play_done if playing?
      end

      def twenty_one
        log(:twenty_one)
        play_done if playing?
      end

      def blackjack
        log(:blackjack)
        @blackjack = true
        @message = "blackjack"
        play_done if playing?
      end

      def clear_cards(discard_stack : CardStack)
        log(:clear_table)
        unless cards.empty?
          if @clearing_card_index >= 0
            card = cards[@clearing_card_index]
            card.move(discard_stack.add_card_position)

            # clear cards
            cards[@clearing_card_index..-1].select(&.moved?).each do |card|
              cards.delete(card)
              discard_stack.add(card)
            end

            @clearing_card_index -= 1
            # delay(deal_delay)
          else
            cards.select(&.moved?).each_with_index do |card|
              cards.delete(card)
              discard_stack.add(card)
            end
          end
        end
      end

      def value(cards = @cards)
        hand = cards.map do |card|
          card.rank.face? ? 10 : card.rank.value
        end.sum

        hand += 10 if cards.any?(&.rank.ace?) && hand + 10 <= 21

        hand
      end

      def display
        hand = cards.map do |card|
          card.rank.face? ? 10 : card.rank.value
        end.sum

        if cards.any?(&.rank.ace?)
          if hand + 10 < 21
            "#{hand}/#{hand + 10}"
          elsif hand + 10 > 21
            "#{hand}"
          else # 21
            if cards.size == 2
              "blackjack 21"
            else
              "#{hand + 10}"
            end
          end
        else
          hand.to_s
        end
      end

      def soft_17?
        value == 17 && cards.size == 2 && cards.any?(&.rank.ace?)
      end
    end
  end
end
