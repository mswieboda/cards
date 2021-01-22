module Cards
  abstract class CardPlayer
    property cards : Array(Card)
    getter? playing
    getter? played
    getter? done
    property? hitting
    getter? bust
    getter? blackjack
    property seat : Seat
    getter message : String
    getter? clearing_table

    @dealing_card : Nil | Card
    @clearing_card_index : Int32

    ACTION_DELAY = 0.33_f32
    DEAL_DELAY = 0.13_f32
    DONE_DELAY = 1.69_f32

    def initialize(@seat = Seat.new, @cards = [] of Card)
      @playing = false
      @played = false
      @done = false
      @hitting = false
      @blackjack = false
      @bust = false
      @elapsed_delay_time = @delay_time = 0_f32
      @message = ""
      @clearing_table = false
      @clearing_card_index = 0
    end

    def update(frame_time)
      cards.each(&.update(frame_time))

      if dealing?
        if dealing_card = @dealing_card
          if dealing_card.moved?
            @dealing_card = nil
          end
        end
      end

      if delay?
        @elapsed_delay_time += frame_time

        if !delay?
          @elapsed_delay_time = 0_f32
          @delay_time = 0_f32
        end
      end
    end

    def draw(screen_x = 0, screen_y = 0)
      cards.each(&.draw(screen_x, screen_y))

      last_y = draw_hand_display(screen_x, screen_y)
      draw_message(screen_x, screen_y, last_y)
    end

    def draw_hand_display(screen_x = 0, screen_y = 0, y = seat.y)
      hand = hand_display
      hand = "" if hand == "0"

      mid_x = seat.x


      text = Game::Text.new(
        text: hand,
        x: (screen_x + mid_x).to_i,
        y: y.to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y -= (CardSpot.margin + text.height).to_i

      text.draw

      text.y
    end

    def draw_message(screen_x = 0, screen_y = 0, y = 0)
      return if message.empty?

      mid_x = seat.x

      text = Game::Text.new(
        text: message,
        x: (screen_x + mid_x).to_i,
        y: y.to_i,
        size: 10,
        spacing: 2,
        color: Game::Color::Black,
      )

      text.x -= (text.width / 2_f32).to_i
      text.y -= (CardSpot.margin + text.height).to_i

      text.draw
    end

    def log_name
      self.class.to_s.split("::").last
    end

    def log(method, message = "")
      return unless Main::DEBUG
      puts ">>> #{log_name}##{method}#{message.presence && " > #{message}"}"
    end

    def card_spots : Array(CardSpot)
      if seat = @seat
        seat.card_spots
      else
        [] of CardSpot
      end
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
      !!@dealing_card
    end

    def dealt?
      !dealing? && cards.size >= 2
    end

    def deal(card : Card)
      log(:deal)

      card.flip if card.flipped?

      position = card_spots[[cards.size, card_spots.size - 1].min].position.clone

      # move over if we've already used all the spots
      position.x += CardSpot.margin * (2 * cards.size - card_spots.size) if cards.size >= card_spots.size

      card.move(position)
      @cards << card
      @dealing_card = card

      delay(deal_delay)
    end

    def play
      log(:play)
      @playing = true
      hand_check
    end

    def hand_check
      log(:hand_check, "hand: #{hand_display} cards: #{cards.map(&.short_name)}")

      hand = hand_value

      if hand > 21
        bust
      elsif hand == 21
        if hand_value(cards[0..1]) == 21
          blackjack
        else
          twenty_one
        end
      end
    end

    def play_done
      log(:play_done)
      @hitting = false
      @playing = false
      @played = true
      delay(done_delay)
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

    def done(_dealer : Dealer)
      log(:done)
      @done = true
      @clearing_card_index = cards.size - 1
      delay(deal_delay)
    end

    def cleared_table?
      log(:cleared_table?, "cards: #{cards.map(&.short_name)} cci: #{@clearing_card_index}")
      cards.empty?
    end

    def clear_table(discard_stack : CardStack)
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
          delay(deal_delay)
        else
          cards.select(&.moved?).each_with_index do |card|
            cards.delete(card)
            discard_stack.add(card)
          end
        end
      end
    end

    def new_hand
      log(:new_hand)
      @message = ""

      @hitting = false
      @playing = false
      @played = false
      @bust = false
      @blackjack = false
      @done = false
      @clearing_table = false
    end

    def hand_value(cards = @cards)
      hand = cards.map do |card|
        card.rank.face? ? 10 : card.rank.value
      end.sum

      hand += 10 if cards.any?(&.rank.ace?) && hand + 10 <= 21

      hand
    end

    def hand_display
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
      hand_value == 17 && cards.size == 2 && cards.any?(&.rank.ace?)
    end
  end
end
