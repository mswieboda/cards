module Cards
  module Solitare
    class GameMode < Cards::GameMode
      getter? exit
      getter? dealt
      getter? clearing_waste

      getter deal_index
      getter deal_row_index

      getter stock : Stock
      getter waste : Waste
      getter stacks : Array(Stack)
      getter foundations : Array(Foundation)
      getter cards : Array(Card)
      getter cards_to_foundation : Array({card: Card, stack: Foundation})
      getter stack_drag : Stack?
      getter stack_drag_delta : Game::Vector
      getter stack_drag_to_stack : CardStack
      getter? stack_drag_released : Bool

      @[JSON::Field(ignore: true)]
      @deck : Deck = StandardDeck.new(jokers: false)

      @[JSON::Field(ignore: true)]
      @menu : Popup = Popup.new(items: %w(new save load back exit))

      @[JSON::Field(ignore: true)]
      @menu_load : Popup = Popup.new(items: %w(back))

      @[JSON::Field(ignore: true)]
      @menu_save : SaveMenu = SaveMenu.new

      MARGIN = 25
      FAN_STACKS = 7
      DEAL_CARDS = (FAN_STACKS + 1).times.to_a.sum

      SAVE_PATH = "./saves/solitare"

      def initialize
        super

        @exit = false
        @deal_index = 0
        @deal_row_index = 0
        @dealt = false
        @clearing_waste = false

        @stock = Stock.new(
          x: MARGIN,
          y: MARGIN,
          cards: @deck.cards.clone.shuffle!
        )

        @waste = Waste.new(
          x: @stock.x + Card.width + MARGIN * 2,
          y: MARGIN
        )

        @stacks = FAN_STACKS.times.to_a.map do |index|
          Stack.new(
            x: @stock.x + index * (MARGIN * 2 + Card.width),
            y: @stock.y + Card.height + MARGIN * 2
          )
        end

        @foundations = Suit.values.map_with_index do |suit, index|
          Foundation.new(
            suit: suit,
            x: Main.screen_width - MARGIN - Card.width - index * (MARGIN * 2 + Card.width),
            y: MARGIN
          )
        end

        @cards = [] of Card
        @stack_drag = nil
        @stack_drag_delta = Game::Vector.zero
        @stack_drag_to_stack = @waste
        @stack_drag_released = false

        @cards_to_foundation = [] of {card: Card, stack: Foundation}

        menu_handlers
        create_save_dirs
      end

      def update(frame_time)
        @cards.each(&.update(frame_time))
        @cards_to_foundation.map(&.[:card]).each(&.update(frame_time))

        ([@waste] + @stacks).each(&.update(frame_time))

        deal if !dealt?

        return if update_menus(frame_time)
        return unless dealt?
        return if clear_waste(frame_time)
        return if move_cards_to_waste
        return if move_cards_to_foundation
        return if flip_up_stack_top_card
        return if drag_stack(frame_time)
      end

      def draw
        super

        @stock.draw(@deck)
        @waste.draw(@deck)
        @foundations.each(&.draw(@deck))
        @stacks.each(&.draw(@deck))
        @cards.each(&.draw(@deck))
        @cards_to_foundation.map(&.[:card]).each(&.draw(@deck))

        if stack = @stack_drag
          stack.draw(@deck)
        end

        [@menu, @menu_save, @menu_load].each do |menu|
          menu.draw if menu.shown?
        end
      end

      def move_cards_to_waste
        @cards.select(&.moved?).each do |card|
          @cards.delete(card)
          @waste.add(card)
          card.flip if card.flipped?
        end

        if card = @stock.take_pressed
          # move from stock to waste
          card.move(@waste.add_position)
          @cards << card
          return true
        end
      end

      def move_cards_to_foundation
        @cards_to_foundation.select { |t| t[:card].moved? }.each do |t|
          @cards_to_foundation.delete(t)
          t[:stack].add(t[:card])
        end

        if stack = ([@waste] + @stacks).find{ |s| s.any? && s.double_clicked? }
          if foundation = @foundations.find(&.add?(stack.cards.last))
            card = stack.take
            card.move(foundation.add_position)
            @cards_to_foundation << {card: card, stack: foundation}
            return true
          end
        end
      end

      def flip_up_stack_top_card
        if stack = @stacks.find(&.flip_up_top_card?)
          stack.flip_up_top_card
          return true
        end
      end

      def drag_stack(frame_time)
        # check for drag stack from waste or stacks
        ([@waste] + @stacks + @foundations).each do |stack|
          if stack_drag = stack.take_pressed_stack
            @stack_drag = stack_drag
            @stack_drag_delta = Game::Mouse.position - stack_drag.position
            @stack_drag_to_stack = stack
            return true
          end
        end

        # if we're dragging a stack
        if stack = @stack_drag
          stack.update(frame_time)

          if @stack_drag_released
            if stack.moved?
              # add to target stack
              @stack_drag_to_stack.add(stack)
              @stack_drag = nil
              @stack_drag_delta = Game::Vector.zero
              @stack_drag_released = false
            end
          else
            # move stack with mouse
            stack.x = Game::Mouse.x - @stack_drag_delta.x
            stack.y = Game::Mouse.y - @stack_drag_delta.y

            # release stack
            unless Game::Mouse::Left.down?
              stack.move(@stack_drag_to_stack.add_position)
              @stack_drag_released = true
            end
          end
        end
      end

      def clear_waste(frame_time)
        if @stock.empty? && @stock.pressed?
          @clearing_waste = true

          @waste.cards.each_with_index do |card, index|
            card.move(@stock.add_position(index))
          end

          return true
        end

        return unless clearing_waste?

        @waste.update(frame_time)

        if @waste.cards.all?(&.moved?)
          @waste.flip!

          @stock.add(@waste)
          @stock.update_cards_position

          @clearing_waste = false
        end

        true
      end

      def deal_stack_index(prev_row = false)
        spaces = (@deal_row_index + 1).times.to_a.sum
        (@deal_index + spaces) % @stacks.size
      end

      def deal
        @cards.select(&.moved?).each do |card|
          stack_index = deal_stack_index
          stack = @stacks[stack_index]

          stack.add(card)
          @cards.delete(card)

          card.flip if stack.size >= stack_index + 1

          @deal_row_index += 1 if stack_index >= @stacks.size - 1
          @deal_index += 1
        end

        return true if @cards.any?(&.moving?)

        if @deal_index >= DEAL_CARDS
          @dealt = true
          return true
        end

        card = @stock.take
        card.move(@stacks[deal_stack_index].add_position)
        @cards << card
      end

      def menu_handlers
        # menu
        @menu.on("save") do
          @menu_save.show
        end

        @menu.on("load") do
          @menu_load.show

          path = Dir.new(Game::Utils.expand_path(SAVE_PATH))
          items = path.children.select(&.ends_with?(".cc_save")).map do |file_path|
            Path[file_path].normalize
          end

          @menu_load.items = items.map(&.stem) + ["back"]

          items.each do |item|
            @menu_load.on(item.stem) do
              load(item)
            end
          end
        end

        # save
        @menu_save.on("input_name") do
          save
        end

        @menu_save.on("save") do
          save
        end

        # load
        @menu_load.on("back") do
          @menu.show
        end
      end

      def create_save_dirs
        Dir.mkdir_p(Game::Utils.expand_path(SAVE_PATH))
      end

      def update_menus(frame_time)
        [@menu, @menu_save, @menu_load].each do |menu|
          if menu.shown?
            menu.update(frame_time)

            menu.hide if menu.done?
            exit if menu.exit?

            return true
          end
        end

        if Key.menu.pressed?
          @menu.show
          return true
        end
      end

      def save
        path = Path[Game::Utils.expand_path(SAVE_PATH)].join("#{@menu_save.name}.cc_save")

        puts ">>> saving #{self.class.to_s}:"
        json = to_json
        puts json

        File.write(path, json)

        puts ">>> save #{path}"
      end

      def load(file_name : Path)
        file_path = Path[Game::Utils.expand_path(SAVE_PATH)].join(file_name)
        puts ">>> load #{file_path}"

        json = File.read(file_path)
        game = Solitare::GameMode.from_json(json)

        load_from(game)
      end

      def load_from(game : Solitare::GameMode)
        @exit = game.exit?
        @dealt = game.dealt?
        @clearing_waste = game.clearing_waste?
        @game_over = game.game_over?

        @deal_index = game.deal_index
        @deal_row_index = game.deal_row_index

        @stock = game.stock
        @waste = game.waste
        @stacks = game.stacks
        @foundations = game.foundations
        @cards = game.cards
        @stack_drag = game.stack_drag
        @stack_drag_delta = game.stack_drag_delta
        @stack_drag_to_stack = game.stack_drag_to_stack
        @stack_drag_released = game.stack_drag_released?
      end
    end
  end
end
