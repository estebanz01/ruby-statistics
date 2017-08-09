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

      def density_function(value)
        return 0 if standard_deviation <= 0

        up_right = (value - mean)**2.0
        down_right = 2.0 * variance
        right = Math.exp(-(up_right/down_right))
        left_down = Math.sqrt(2.0 * Math::PI * variance)
        left_up = 1.0

        (left_up/(left_down) * right)
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
