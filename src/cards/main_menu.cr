require "./menu"

module Cards
  class MainMenu < Menu
    getter? exit

    def initialize
      super(%w(blackjack options exit))
    end

    def select_item
      item = @items[@focus_index]

      if item.text == "blackjack"
        @done = true
      elsif item.text == "exit"
        @exit = true
      end
    end

    def back
      @exit = true
    end

    def draw
      return unless shown?

      draw_header("cards")
      super
    end
  end
end
