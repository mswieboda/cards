module Cards
  class ChipTray < ChipStack
    def draw(screen_x = 0, screen_y = 0)
      # TODO: flip chips horizontal and vertical
      @chips.each(&.draw(screen_x, screen_y))
    end
  end
end
