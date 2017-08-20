module Statistics
  module Distribution
    class TStudent
      attr_accessor :degrees_of_freedom
      attr_reader :mode

      def initialize(v)
        self.degrees_of_freedom = v
        @mode = 0
      end

      ### Extracted from https://codeplea.com/incomplete-beta-function-c
      ### This function is shared under zlib license and the author is Lewis Van Winkle
      def cumulative_function(value)
        upper = (value + Math.sqrt(value * value + degrees_of_freedom))
        lower = (2.0 * Math.sqrt(value * value + degrees_of_freedom))

        x = upper/lower

        alpha = degrees_of_freedom/2.0
        beta = degrees_of_freedom/2.0

        Distribution::Beta.incomplete_beta_function(x, alpha, beta)
      end

      def density_function(value)
        return if degrees_of_freedom <= 0

        upper = Math.gamma((degrees_of_freedom + 1)/2.0)
        lower = Math.sqrt(degrees_of_freedom * Math::PI) * Math.gamma(degrees_of_freedom/2.0)
        left = upper/lower
        right = (1 + ((value ** 2)/degrees_of_freedom.to_f)) ** -((degrees_of_freedom + 1)/2.0)

        left * right
      end

      def mean
        0 if degrees_of_freedom > 1
      end

      def variance
        if degrees_of_freedom > 1 && degrees_of_freedom <= 2
          Float::INFINITY
        elsif degrees_of_freedom > 2
          degrees_of_freedom/(degrees_of_freedom - 2.0)
        end
      end
    end
  end
end
