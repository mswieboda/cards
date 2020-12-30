require "game"

require "./cards/**"

module Cards
  def self.run
    Main.new.run
  end
end

Cards.run
