module Cards
  abstract class Deck
    include JSON::Serializable

    property back : CardBack
    property front : CardFront
    property cards : Array(Card)
    getter? jokers

    delegate :size, :empty?, :any?, to: cards

    def initialize(@back = CardBacks::Bordered.new, @front = CardFronts::Standard.new, @jokers = true, @cards = [] of Card)
    end

    def shuffle!
      @cards.shuffle!
    end
  end
end
