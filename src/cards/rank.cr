module Cards
  enum Rank : UInt8
    Ace = 1
    Two
    Three
    Four
    Five
    Six
    Seven
    Eight
    Nine
    Ten
    Jack
    Queen
    King
    Joker

    def name
      to_s
    end

    def numeral?
      value > 1 && value < 11
    end

    def face?
      in?(Jack, Queen, King)
    end

    def short_name
      case self
      when Joker
        "JKR"
      when .numeral?
        value.to_s
      else
        name[0].to_s
      end
    end
  end
end
