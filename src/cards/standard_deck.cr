module Cards
  class StandardDeck < Deck
    property? joker

    def initialize(@joker = false, flipped = false)
      cards = [] of Card

      Suit.values.each do |suit|
        Rank.values.each do |rank|
          next if rank.joker? && !joker?

          cards << Card.new(rank: rank, suit: suit, flipped: flipped)
        end
      end

      super(cards)
    end
  end
end
