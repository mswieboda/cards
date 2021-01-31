module Cards
  module Solitare
    class GameMode < Cards::GameMode
      def initialize
        super

        @deck = StandardDeck.new(jokers: false)
      end

      def update(_frame_time)
      end

      def draw
        super
      end
    end
  end
end
