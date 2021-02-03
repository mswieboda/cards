module Cards
  class SaveMenu < Popup
    def initialize(title = "save")
      super(title: title, items: %w(input_name save back))

      @handlers = Hash(String, Proc(Nil)).new

      self.on("back") do
        back
      end
    end

    def name
      if item = @items.find { |i| i.name == "input_name" }
        item.text
      else
        ""
      end
    end

    def select_item
      item = @items[@focus_index]

      if callback = @handlers[item.name]?
        @done = true
        callback.call
      end
    end

    def back
      @done = true
    end

    def on(item, &block : Proc(Nil))
      @handlers[item] = block
    end
  end
end
