module Cards
  module Blackjack
    abstract class CardPlayer
      getter seat : Seat
      getter chip_tray : ChipTray
      getter hands : Array(Hand)
      getter? playing
      getter? done

      @hand_index : Int32

      ACTION_DELAY = 0.33_f32
      DEAL_DELAY = 0.13_f32
      DONE_DELAY = 1.69_f32

      def initialize(@seat = Seat.new, @chip_tray = ChipTray.new, @hands = [] of Hand)
        @done = false
        @elapsed_delay_time = @delay_time = 0_f32
        @hands << Hand.new if @hands.empty?
        @hand_index = 0

        update_positions
      end

      def seat=(seat : Seat)
        @seat = seat
        update_positions
        @seat
      end

      def current_hand
        hands[@hand_index]
      end

      def update_positions
        chip_tray.update_positions(@seat)
        hands.each_with_index do |hand, index|
          hand.x = @seat.x
          hand.y = @seat.y + index * (Card.margin + Card.height)
        end
      end

      def update(frame_time)
        hands.each(&.update(frame_time))

        if delay?
          @elapsed_delay_time += frame_time

          if !delay?
            @elapsed_delay_time = 0_f32
            @delay_time = 0_f32
          end
        end
      end

      def draw(deck : Deck, screen_x = 0, screen_y = 0)
        chip_tray.draw(screen_x, screen_y)

        draw_hands(deck, screen_x, screen_y)
      end

      def draw_bets?
        false
      end

      def draw_hands(deck : Deck, screen_x, screen_y)
        hands.each(&.draw(deck: deck, screen_x: screen_x, screen_y: screen_y, bets: draw_bets?))
      end

      def log_name
        self.class.to_s.split("::").last
      end

      def log(method, message = "")
        return unless Main.debug?
        puts ">>> #{log_name}##{method}#{message.presence && " > #{message}"}"
      end

      def unseated?
        @seat.no_seat?
      end

      def delay?
        @delay_time > 0_f32 && @elapsed_delay_time < @delay_time
      end

      def delay(sec : Int32 | Float32)
        @elapsed_delay_time = 0_f32
        @delay_time = sec
      end

      def action_delay
        ACTION_DELAY
      end

      def deal_delay
        DEAL_DELAY
      end

      def done_delay
        DONE_DELAY
      end

      def dealing?
        hands.any?(&.dealing?)
      end

      def dealt?
        hands.all?(&.dealt?)
      end

      def splitting?
        false
      end

      def playing?
        hands.any?(&.playing?)
      end

      def played?
        hands.all?(&.played?)
      end

      def hitting?
        hands.any?(&.hitting?)
      end

      def hitting=(value : Bool)
        if hand = current_hand
          hand.hitting = value
        end
      end

      def next_hand
        @hand_index += 1 unless @hand_index + 1 >= @hands.size
      end

      def next_turn
        @hand_index = 0
      end

      def deal(card_stack : CardStack)
        log(:deal)

        if hand = current_hand
          hand.deal(card_stack)

          next_hand

          delay(deal_delay)
        end
      end

      def play
        log(:play)

        if hand = current_hand
          hand.playing = true
        end

        hand_check
      end

      def hand_check
        log(:hand_check)

        if hand = current_hand
          hand.check
          next_hand if hand.played?
        end
      end

      def done(_dealer : Dealer)
        log(:done)
        @done = true
        delay(deal_delay)
      end

      def cleared_table?
        hands.all?(&.cleared_table?)
      end

      def clear_table(discard_stack : CardStack)
        hands.each(&.clear_cards(discard_stack))
      end

      def new_hand
        log(:new_hand)

        @done = false

        hands.clear
        @hands << Hand.new
        @hand_index = 0
        update_positions
      end
    end
  end
end
