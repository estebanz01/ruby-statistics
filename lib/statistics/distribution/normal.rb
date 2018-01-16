module Statistics
  module Distribution
    class Normal
      attr_accessor :mean, :standard_deviation, :variance
      alias_method :mode, :mean

      def initialize(avg, std)
        self.mean = avg.to_f
        self.standard_deviation = std.to_f
        self.variance = std.to_f**2
      end

      def cumulative_function(value)
        (1/2.0) * (1.0 + Math.erf((value - mean)/(standard_deviation * Math.sqrt(2.0))))
      end

      def density_function(value)
        return 0 if standard_deviation <= 0

        up_right = (value - mean)**2.0
        down_right = 2.0 * variance
        right = Math.exp(-(up_right/down_right))
        left_down = Math.sqrt(2.0 * Math::PI * variance)
        left_up = 1.0

        (left_up/(left_down) * right)
      end

      ## Marsaglia polar method implementation for random gaussian (normal) number generation.
      # References:
      # https://en.wikipedia.org/wiki/Marsaglia_polar_method
      # https://math.stackexchange.com/questions/69245/transform-uniform-distribution-to-normal-distribution-using-lindeberg-l%C3%A9vy-clt
      # https://www.projectrhea.org/rhea/index.php/The_principles_for_how_to_generate_random_samples_from_a_Gaussian_distribution

      def random(elements: 1, seed: Random.new_seed)
        results = []

        # Setup seed
        srand(seed)

        # Number of random numbers to be generated.
        elements.times do
          x, y, r = 0.0, 0.0, 0.0

          # Find an (x, y) point in the x^2 + y^2 < 1 circumference.
          loop do
            x = 2.0 * rand - 1.0
            y = 2.0 * rand - 1.0

            r = (x ** 2) + (y ** 2)

            break unless r >= 1.0 || r == 0
          end

          # Project the random point to the required random distance
          r = Math.sqrt(-2.0 * Math.log(r) / r)

          # Transform the random distance to a gaussian value and append it to the results array
          results << mean + x * r * standard_deviation
        end

        if elements == 1
          results.first
        else
          results
        end
      end
    end

    class StandardNormal < Normal
      def initialize
        super(0, 1) # Mean = 0, Std = 1
      end

      def density_function(value)
        pow = (value**2)/2.0
        euler = Math.exp(-pow)

        euler/Math.sqrt(2 * Math::PI)
      end
    end
  end
end
