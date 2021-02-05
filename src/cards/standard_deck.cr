module Cards
  class StandardDeck < Deck
    def initialize(@back = CardBacks::Stripes.new, @jokers = false, flipped = true)
      cards = [] of Card

      # adds 52 standard cards from diamonds, clubs, hearts, spades
      Suit.values.each do |suit|
        Rank.values.each do |rank|
          next if rank.joker?
          cards << Card.new(rank: rank, suit: suit, flipped: flipped)
        end
      end

      # adds 2 jokers
      if jokers?
        cards << Card.new(rank: Rank::Joker, suit: Suit::Hearts, flipped: flipped)
        cards << Card.new(rank: Rank::Joker, suit: Suit::Spades, flipped: flipped)
      end

      super(
        back: back,
        jokers: @jokers,
        cards: cards
      )
    end
  end
end
