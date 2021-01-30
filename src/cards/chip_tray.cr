module Cards
  class ChipTray
    getter chip_stacks : Hash(Chip::Amount, ChipStack)
    getter selected_chip : Chip | Nil

    @chip_amounts : Hash(Chip::Amount, Chip)
    @y : Int32 | Float32

    MAX_CHIPS = 10

    def initialize(@y = 0, balance = 0)
      @chip_stacks = Hash(Chip::Amount, ChipStack).new
      @chip_amounts = Hash(Chip::Amount, Chip).new

      leftover_balance = balance

      Chip::Amount.values.each_with_index do |amount, index|
        chip_stack = ChipStack.new(selectable: true)

        # add chips to chip stack
        [(leftover_balance / amount.value).to_i, amount.default_chip_stack].min.times do
          leftover_balance -= amount.value
          chip_stack.add(Chip.new(amount: amount))
        end

        if next_amount = Chip::Amount.values[index + 1]?
          ((leftover_balance % next_amount.value) / amount.value).to_i.times do
            leftover_balance -= amount.value
            chip_stack.add(Chip.new(amount: amount))
          end
        end

        chip_stacks[amount] = chip_stack
        @chip_amounts[amount] = Chip.new(amount: amount)
      end
    end

    def update_positions(seat : Seat)
      @chip_stacks.each_with_index do |(amount, chip_stack), index|
        start_x = seat.x - Chip::Amount.values.size / 2_f32 * (ChipStack.width + Card.margin) + Card.margin / 2_f32
        chip_stack.x = start_x + index * (ChipStack.width + Card.margin)
        chip_stack.y = @y
      end
    end

    def update(frame_time)
      @chip_stacks.each { |(_a, cs)| cs.update(frame_time) }

      @selected_chip = nil

      Chip::Amount.values.each { |amount| update_select_chip(amount) }
    end

    def update_select_chip(amount : Chip::Amount)
      return if @selected_chip

      if chip_stack = @chip_stacks[amount]
        if Key.bet(amount).pressed? || chip_stack.selected?
          @selected_chip = chip_stack.take if chip_stack.any?
        end
      end
    end

    def draw(screen_x, screen_y)
      @chip_stacks.each do |(amount, chip_stack)|
        chip_stack.draw(screen_x, screen_y)

        if chip_stack.empty?
          if chip = @chip_amounts[amount]
            chip.draw(
              screen_x: screen_x + chip_stack.x,
              screen_y: screen_y + chip_stack.y,
              alpha: chip_stack.hovered? ? 126_u8 : 33_u8
            )
          end
        end
      end
    end

    def chip_value
      @chip_stacks.map { |(_a, chip_stack)| chip_stack.chip_value }.sum
    end

    def add_position(chip : Chip)
      if chip_stack = @chip_stacks[chip.amount]
        chip_stack.add_position
      end
    end

    def add(chip : Chip)
      if chip_stack = @chip_stacks[chip.amount]
        chip_stack.add(chip)
      end
    end

    def largest(bet) : Chip | Nil
      Chip::Amount.values.reverse.each do |amount|
        next if amount.value > bet

        if chip_stack = @chip_stacks[amount]
          next if chip_stack.empty?

          return chip_stack.take
        end
      end
    end
  end
end
