module Cards
  enum Suit
    Diamonds
    Clubs
    Hearts
    Spades

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
