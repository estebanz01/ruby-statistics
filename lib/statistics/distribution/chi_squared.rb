module Statistics
  module Distribution
    class ChiSquared
      attr_accessor :degrees_of_freedom

      alias_method :mean, :degrees_of_freedom

      def initialize(k)
        self.degrees_of_freedom = k
      end

      # Function adapted from the python implementation that exists in https://en.wikipedia.org/wiki/Simpson%27s_rule#Sample_implementation
      # Finite integral in the interval [a, b] split up in n-intervals
      def self.simpson_rule(a, b, n, &block)
        unless n.even?
          puts "The composite simpson's rule needs even intervals!"
          return
        end

        h = (b - a)/n.to_f
        resA = yield(a)
        resB = yield(b)

        sum = resA + resB

        (1..n).step(2).each do |number|
          res = yield(a + number * h)
          sum += 4 * res
        end

        (1..(n-1)).step(2).each do |number|
          res = yield(a + number * h)
          sum += 2 * res
        end

        return sum * h / 3.0
      end

      def self.lower_incomplete_gamma_function(s, x)
        # The greater the iterations, the better. That's why we are iterating 10_000 * x times
        self.simpson_rule(0, x, (10_000 * x).round) do |t|
          (t ** (s - 1)) * Math.exp(-t)
        end
      end

      def cumulative_function(value)
        k = degrees_of_freedom/2.0
        self.class.lower_incomplete_gamma_function(k, value/2.0)/Math.gamma(k)
      end

      def density_function(value)
        return 0 if value < 0

        common = degrees_of_freedom/2.0

        left_down = (2 ** common) * Math.gamma(common)
        right = (value ** (common - 1)) * Math.exp(-(value/2.0))

        (1.0/left_down) * right
      end

      def mode
        [degrees_of_freedom - 2, 0].max
      end

      def variance
        degrees_of_freedom * 2
      end
    end
  end
end
