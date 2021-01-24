module Cards
  class Key
    def initialize
    end

    def self.up_keys
      [Game::Key::Down, Game::Key::S]
    end

    def self.down_keys
      [Game::Key::Down, Game::Key::S]
    end

    def self.select_keys
      [Game::Key::Enter, Game::Key::Space, Game::Key::LShift, Game::Key::RShift]
    end

    def self.cancel_keys
      [Game::Key::Escape, Game::Key::Backspace]
    end

    def self.stand
      Game::Key::Space
    end

    def self.hit
      Game::Key::Enter
    end

    def self.confirm_bet_keys
      [Game::Key::Space, Game::Key::LShift, Game::Key::RShift, Game::Key::Enter]
    end
  end
end
