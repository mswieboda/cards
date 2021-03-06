module Cards
  module Blackjack
    class Key < Cards::Key
      def self.stand
        Game::Key::Space
      end

      def self.hit
        Game::Key::Enter
      end

      def self.double_down
        Game::Key::D
      end

      def self.split
        Game::Key::S
      end

      def self.confirm_bet_keys
        [Game::Key::Space, Game::Key::LShift, Game::Key::RShift, Game::Key::Enter]
      end

      def self.bet(amount : Chip::Amount) : Game::Key
        case amount
        when Chip::Amount::One
          Game::Key::One
        when Chip::Amount::Five
          Game::Key::Two
        when Chip::Amount::Twenty
          Game::Key::Three
        when Chip::Amount::Fifty
          Game::Key::Four
        when Chip::Amount::Hundred
          Game::Key::Five
        else
          # shouldn't happen, but needed in order to be
          # Game::Key instead of Game::Key | Nil
          Game::Key::One
        end
      end

      def self.clear_bet
        Game::Key::Backspace
      end
    end
  end
end
