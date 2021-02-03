module Cards
  class MenuItemInput < MenuItem
    @input : Game::TextInput

    def initialize(@name, x = 0, y = 0, text = "", color = Game::Color::Lime, @focused = false, @padding = PADDING)
      @text = Game::TextInput.new(
        text: text,
        x: x + @padding,
        y: y + @padding,
        size: TEXT_SIZE,
        spacing: 5,
        color: color
      )
      @input = @text.as(Game::TextInput)
      @input.focused = @focused
    end

    def update(frame_time)
      @input.update(frame_time)
    end

    def focus
      super
      @input.focused = true
    end

    def blur
      super
      @input.focused = false
    end
  end
end
