require "./menu"

module Cards
  class Popup < Menu
    getter title

    def initialize(@title = "", items = [] of String)
      super(items)
      @handlers = Hash(String, Proc(Nil)).new
    end

    def select_item
      item = @items[@focus_index]

      if callback = @handlers[item.text]?
        @done = true
        callback.call
      end

      if item.text == "exit"
        @exit = true
      end
    end

    def back
      @done = true
    end

    def draw
      return unless shown?

      draw_header(title) unless title.empty?
      super
    end

    def on(item, &block : Proc(Nil))
      @handlers[item] = block
    end
  end
end
