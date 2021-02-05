module Cards
  enum Suit
    Clubs
    Diamonds
    Spades
    Hearts

    def self.sym_from_sprite_string(string : String)
      case string
      when "diamonds"
        :diamonds
      when "clubs"
        :clubs
      when "hearts"
        :hearts
      when "spades"
        :spades
      else
        raise "Suit.sym_from_sprite_string error sym not found: #{string}"
      end
    end

    def sprite_sym
      case self
      when Diamonds
        :diamonds
      when Clubs
        :clubs
      when Hearts
        :hearts
      when Spades
        :spades
      else
        raise "Suit#sprite_sym error suit not found: #{self}"
      end
    end

    def name
      to_s
    end

    def short_name
      # TODO: use unicode/emojis for the symbols
      name[0].to_s
    end

    def color
      case self
      when .in?(Diamonds, Hearts)
        Game::Color::Red
      else
        Game::Color::Black
      end
    end

    def pair?(suit : Suit)
      case self
      when .in?(Diamonds, Hearts)
        suit.in?(Diamonds, Hearts)
      else
        suit.in?(Clubs, Spades)
      end
    end
  end
end
