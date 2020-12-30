module Cards
  class MenuItem
    PADDING = 25
    TEXT_SIZE = 21

    getter? focused

    @padding : Int32

    delegate :text, to: @text

    def initialize(x = 0, y = 0, text = "", color = Game::Color::Lime, @focused = false, @padding = PADDING)
      @text = Game::Text.new(
        text: text,
        x: x + @padding,
        y: y + @padding,
        size: TEXT_SIZE,
        spacing: 5,
        color: color
      )
    end

    def focus
      @focused = true
    end

    def blur
      @focused = false
    end

    def x
      @text.x.to_f32 - @padding
    end

    def x=(value : Int32 | Float32)
      @text.x = value + @padding
    end

    def y
      @text.y.to_f32 - @padding
    end

    def y=(value : Int32 | Float32)
      @text.y = value + @padding
    end

    def width
      @text.width + @padding * 2
    end

    def height
      @text.height + @padding * 2
    end

    def draw
      @text.draw
      draw_focused
    end

    def draw_focused
      return unless focused?

      Game::Rectangle.new(
        x: x,
        y: y,
        width: width,
        height: height,
        color: @text.color,
        filled: false
      ).draw
    end
  end
end
