module Cards
  abstract class Menu
    getter? shown
    getter? exit
    property? done

    @items : Array(MenuItem)

    def initialize(items : Array(String))
      @shown = false
      @exit = false
      @focus_index = 0
      @done = false

      @items = items.map { |item| item.starts_with?("input_") ? MenuItemInput.new(name: item) : MenuItem.new(name: item) }

      arrange_items
    end

    def items=(items : Array(String))
      @items = items.map { |item| item.starts_with?("input_") ? MenuItemInput.new(name: item) : MenuItem.new(name: item) }

      arrange_items
    end

    def items_width
      @items.map(&.width).max
    end

    def items_height
      @items.map(&.height).sum
    end

    def arrange_items
      x = Main.screen_width / 2_f32
      y = Main.screen_height / 2_f32 - items_height / 2_f32

      @items.each do |item|
        item.x = x - item.width / 2_f32
        item.y = y

        y += item.height
      end
    end

    def update(frame_time)
      return unless shown?

      @items.select(&.is_a?(MenuItemInput)).map(&.as(MenuItemInput)).each do |menu_item_input|
        menu_item_input.update(frame_time)
        menu_item_input.x = Main.screen_width / 2_f32 - menu_item_input.width / 2_f32

        if menu_item_input.focused?
          if Game::Key::Down.pressed?
            focus_next
          elsif Game::Key::Up.pressed?
            focus_last
          elsif Game::Key::Enter.pressed?
            select_item
          elsif Game::Key::Escape.pressed?
            back
          end

          return
        end
      end

      if Game::Keys.pressed?(Key.down_keys)
        focus_next
      elsif Game::Keys.pressed?(Key.up_keys)
        focus_last
      elsif Game::Keys.pressed?(Key.select_keys)
        select_item
      elsif Game::Keys.pressed?(Key.cancel_keys)
        back
      end
    end

    def draw
      return unless shown?

      draw_background

      @items.each(&.draw)
    end

    def draw_background
      padding = 50

      x = Main.screen_width / 2_f32
      y = Main.screen_height / 2_f32 - items_height / 2_f32

      Game::Rectangle.new(
        x: x - items_width / 2_f32 - padding,
        y: y - padding,
        width: items_width + padding * 2,
        height: items_height + padding * 2,
        color: Game::Color::Black,
      ).draw
    end

    def draw_header(text : String)
      padding = 25

      x = Main.screen_width / 2_f32
      y = padding

      item = MenuItem.new(name: text, x: x, y: y, padding: padding)
      item.x = x - item.width / 2_f32

      Game::Rectangle.new(
        x: item.x,
        y: item.y,
        width: item.width,
        height: item.height,
        color: Game::Color::Black,
      ).draw

      item.draw
    end

    def back
      # to be overriden
    end

    def focus_next
      focus
    end

    def focus_last
      focus(asc: false)
    end

    def focus(asc = true, wrap = true)
      @items[@focus_index].blur

      @focus_index += asc ? 1 : -1

      if wrap
        if @focus_index >= @items.size
          @focus_index = 0
        elsif @focus_index < 0
          @focus_index = @items.size - 1
        end
      end

      @items[@focus_index].focus
    end

    def select_item
      # to be overriden
    end

    def show
      @shown = true
      @items[@focus_index].focus
    end

    def hide
      @shown = false
      @done = false

      @items[@focus_index].blur
    end
  end
end
