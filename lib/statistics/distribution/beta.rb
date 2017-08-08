module Statistics
  module Distribution
    class Beta
      attr_accessor :alpha, :beta

      def initialize(alp, bet)
        self.alpha = alp
        self.beta = bet
      end

      def probability_density(value)
        return 0 if value > 1 || value < 0 # Outside support
        return 1 if alpha == 1 && beta == 1

        if(alpha < 512 && beta < 512)
          ((value**(alpha - 1)) * (1 - value)**(beta - 1))/beta_function(alpha, beta)
        else
          Math.exp((alpha - 1) * Math.log(value) + (beta - 1) * Math.log(1 - x) - beta_function)
        end
      end
    end
  end
end
