module Cards
  abstract class CardPlayer
    property card_spots : Array(CardSpot)
    property cards : Array(Card)
    getter? playing
    getter? played
    getter? done
    property? hitting
    getter? bust
    getter? blackjack

    @dealing_card : Nil | Card

    ACTION_DELAY = 0.33_f32
    DEAL_DELAY = ACTION_DELAY
    DONE_DELAY = 1.69_f32

    def initialize(@card_spots = [] of CardSpot, @cards = [] of Card)
      @playing = false
      @played = false
      @done = false
      @hitting = false
      @blackjack = false
      @bust = false
      @elapsed_delay_time = @delay_time = 0_f32
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

        return false
      end

      # used to avoid early exit (from delay) in child classes
      true
    end

    def draw(screen_x = 0, screen_y = 0)
      card_spots.each(&.draw(screen_x, screen_y))
      cards.each(&.draw(screen_x, screen_y))
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
      card.flip if card.flipped?

      position = card_spots[[cards.size, card_spots.size - 1].min].position.copy

      # move over if we've already used all the spots
      position.x += CardSpot.margin * (2 * cards.size - card_spots.size) if cards.size >= card_spots.size

      card.move(position)
      @cards << card
      @dealing_card = card

      delay(deal_delay)
    end

    def play
      puts ">>> #{self.class}#play" if Main::DEBUG
      @playing = true
      hand_check
    end

    def hand_check
      puts ">>> #{self.class}#hand_check, hand: #{hand_display} cards: #{cards.map(&.short_name)}" if Main::DEBUG

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
      puts ">>> #{self.class}#play_done" if Main::DEBUG
      @hitting = false
      @playing = false
      @played = true
      delay(done_delay)
    end

    def stand
      puts ">>> #{self.class}#stand" if Main::DEBUG
      play_done if playing?
    end

    def hit
      puts ">>> #{self.class}#hit" if Main::DEBUG
      @hitting = true
      delay(action_delay)
    end

    def bust
      puts ">>> #{self.class}#bust" if Main::DEBUG
      @bust = true
      play_done if playing?
    end

    def twenty_one
      puts ">>> #{self.class}#twenty_one" if Main::DEBUG
      play_done if playing?
    end

    def blackjack
      puts ">>> #{self.class}#blackjack" if Main::DEBUG
      @blackjack = true
      play_done if playing?
    end

    def done(_dealer : Dealer)
      puts ">>> #{self.class}#done" if Main::DEBUG
      @done = true
      delay(deal_delay)
    end

    def new_hand
      puts ">>> #{self.class}#new_hand" if Main::DEBUG

      @hitting = false
      @playing = false
      @played = false
      @bust = false
      @blackjack = false
      @done = false
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
