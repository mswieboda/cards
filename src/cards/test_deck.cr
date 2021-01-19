module Cards
  class TestDeck < Deck
    def initialize(@back = CardBacks::Stripes.new, @jokers = false, flipped = false)
      cards = [] of Card

      Suit.values.each do |suit|
        Rank.values.each do |rank|
          next if rank.joker?
          next if rank.ace? || rank.face?

          # adds each card 5 times, for testing
          5.times do
            cards << Card.new(deck: self, rank: rank, suit: suit, flipped: flipped)
          end
        end
      end

      # adds 2 jokers
      if jokers?
        cards << Card.new(deck: self, rank: Rank::Joker, suit: Suit::Hearts, flipped: flipped)
        cards << Card.new(deck: self, rank: Rank::Joker, suit: Suit::Spades, flipped: flipped)
      end

      super(
        back: back,
        jokers: @jokers,
        cards: cards.reverse
      )
    end
  end
end
