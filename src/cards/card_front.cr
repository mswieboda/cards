module Cards
  abstract class CardFront
    def self.width
      Card.width
    end

    def self.height
      Card.height
    end

    def width
      self.class.width
    end

    def height
      self.class.height
    end

    def draw(card : Card, screen_x, screen_y)
      draw_back(card, screen_x, screen_y)
    end

    def draw_back(card : Card, screen_x, screen_y)
      Game::RoundedRectangle.new(
        x: screen_x,
        y: screen_y,
        width: width,
        height: height,
        roundness: 0.15_f32,
        color: Game::Color::Ivory
      ).draw
    end

    def draw_heading(image : Game::Image, suit : Suit, rank : Rank)
    end

    def draw_rank(image : Game::Image, suit : Suit, rank : Rank)
      if rank.numeral?
        draw_numeral(image, suit, rank)
      elsif rank.face?
        draw_face(image, suit, rank)
      elsif rank.ace?
        draw_ace(image, suit, rank)
      elsif rank.joker?
        draw_joker(image, suit, rank)
      end
    end

    def draw_numeral(image : Game::Image, suit : Suit, rank : Rank)
    end

    def draw_face(image : Game::Image, suit : Suit, rank : Rank)
    end

    def draw_ace(image : Game::Image, suit : Suit, rank : Rank)
    end

    def draw_joker(image : Game::Image, suit : Suit, rank : Rank)
    end
  end
end
