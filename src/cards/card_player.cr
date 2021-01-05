module Cards
  abstract class CardPlayer
    property card_spots : Array(CardSpot)
    property cards : Array(Card)
    getter? playing
    getter? played
    getter? done
    property? hitting

    @dealing_card : Nil | Card

    DONE_DELAY = 0.69_f32

    def initialize(@card_spots = [] of CardSpot, @cards = [] of Card)
      @playing = false
      @played = false
      @done = false
      @hitting = false
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

    def delay(sec : Int32 | Float32)
      @elapsed_delay_time = 0_f32
      @delay_time = sec
    end

    def delay?
      @delay_time > 0_f32 && @elapsed_delay_time < @delay_time
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

      card.move_to = position
      @cards << card
      @dealing_card = card
    end

    def play
      puts ">>> #{self.class}#play" if Main::DEBUG
      @playing = true
    end

    def play_done
      puts ">>> #{self.class}#play_done" if Main::DEBUG
      @playing = false
      @played = true
    end

    def stand
      puts ">>> #{self.class}#stand" if Main::DEBUG
      play_done
    end

    def hit
      puts ">>> #{self.class}#hit" if Main::DEBUG
      @hitting = true
    end

    def bust
      puts ">>> #{self.class}#bust" if Main::DEBUG
      play_done
    end

    def twenty_one
      puts ">>> #{self.class}#twenty_one" if Main::DEBUG
      play_done
    end

    def blackjack
      puts ">>> #{self.class}#blackjack" if Main::DEBUG
      play_done
    end

    def done
      puts ">>> #{self.class}#done" if Main::DEBUG
      delay(DONE_DELAY)
      @done = true
    end

    def new_hand
      puts ">>> #{self.class}#new_hand" if Main::DEBUG
      @playing = false
      @played = false
      @done = false
    end

    def hand_value
      cards.map do |card|
        card.rank.face? ? 10 : card.rank.value
      end.sum
    end

    def soft_17?
      hand_value == 16 && cards.any?(&.rank.ace?)
    end
  end
end
