module Cards
  class StandardDeck < Deck
    property? jokers

    def initialize(@back = CardBacks::Bordered.new, @jokers = false, flipped = false)
      cards = [] of Card

      # adds 52 standard cards from diamonds, clubs, hearts, spades
      Suit.values.each do |suit|
        Rank.values.each do |rank|
          next if rank.joker?
          cards << Card.new(deck: self, rank: rank, suit: suit, flipped: flipped)
        end
      end

      # adds 2 jokers
      if jokers?
        cards << Card.new(deck: self, rank: Rank::Joker, suit: Suit::Hearts, flipped: flipped)
        cards << Card.new(deck: self, rank: Rank::Joker, suit: Suit::Spades, flipped: flipped)
      end

      super(
        back: back,
        cards: cards
      )
    end
  end
end
