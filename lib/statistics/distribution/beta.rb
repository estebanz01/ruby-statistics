module Statistics
  module Distribution
    class Beta
      attr_accessor :alpha, :beta

      def initialize(alp, bet)
        self.alpha = alp.to_f
        self.beta = bet.to_f
      end

      def self.beta_function(x, y)
        return 1 if x == 1 && y == 1

        (Math.gamma(x) * Math.gamma(y))/Math.gamma(x + y)
      end

      def density_function(value)
        return 0 if value < 0 || value > 1 # Density function defined in the [0,1] interval

        num = (value**(alpha - 1)) * ((1 - value)**(beta - 1))
        den = self.class.beta_function(alpha, beta)

        num/den
      end

      def mode
        return unless alpha > 1 && beta > 1

        (alpha - 1)/(alpha + beta - 2)
      end

      def mean
        alpha / (alpha + beta)
      end
    end
  end
end
