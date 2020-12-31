module Cards
  enum Suit
    Diamonds
    Clubs
    Hearts
    Spades

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

    def sprite
      Game::Sprite.get(sprite_sym)
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
      when .in?(Suit::Diamonds, Suit::Hearts)
        Game::Color::Red
      else
        Game::Color::Black
      end
    end
  end
end
