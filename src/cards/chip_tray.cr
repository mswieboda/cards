module Cards
  class ChipTray
    getter chip_stacks : Hash(Chip::Amount, ChipStack)

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
        start_x = seat.x - Chip::Amount.values.size / 2_f32 * (ChipStack.width + CardSpot.margin) + CardSpot.margin / 2_f32
        chip_stack.x = start_x + index * (ChipStack.width + CardSpot.margin)
        chip_stack.y = @y
      end
    end

    def update(frame_time)
      @chip_stacks.each { |(_a, cs)| cs.update(frame_time) }
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

    def add_position(chip : Chip)
      if chip_stack = @chip_stacks[chip.amount]
        chip_stack.add_chip_position
      end
    end

    def add(chip : Chip)
      if chip_stack = @chip_stacks[chip.amount]
        chip_stack.add(chip)
      end
    end

    def selected_chip
      @chip_stacks.each do |(amount, chip_stack)|
        if chip_stack.selected?
          if chip = chip_stack.selected_chip
            return chip
          end
        end
      end
    end
  end
end
