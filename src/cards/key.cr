module Cards
  class Key
    def self.up_keys
      [Game::Key::Up, Game::Key::W]
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

    def self.exit
      Game::Key::Escape
    end

    def self.menu
      Game::Key::Escape
    end
  end
end
