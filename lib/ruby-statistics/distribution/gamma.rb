# frozen_string_literal: true

module RubyStatistics
  module Distribution
    class Gamma
      attr_reader :shape, :scale, :rate

      def initialize(shape:, scale: nil)
        @shape = shape
        @scale = scale

        # If the scale is nil, it means we want the distribution to behave with a rate parameter
        # instead of a scale parameter
        @rate = if scale.nil?
                  1.0 / shape
                else
                  nil
                end
      end

      def as_rate?
        scale.nil?
      end

      def mean
        if as_rate?
          self.shape / self.rate
        else
          self.shape * self.scale
        end
      end

      def mode
        return 0.0 if self.shape < 1.0

        if as_rate?
          (self.shape - 1.0) / self.rate
        else
          (self.shape - 1.0) * self.scale
        end
      end

      def variance
        if as_rate?
          self.shape / (self.rate ** 2.0)
        else
          self.shape * (self.scale ** 2.0)
        end
      end

      def skewness
        2.0 / Math.sqrt(self.shape)
      end

      def density_function(x)
        euler = if as_rate?
                  Math.exp(- self.rate * x)
                else
                  Math.exp(-x / self.scale.to_r)
                end

        left = if as_rate?
                 (self.rate ** self.shape).to_r / Math.gamma(self.shape).to_r
               else
                 1r / (Math.gamma(self.shape).to_r * (self.scale ** self.shape).to_r)
               end

        left * (x ** (self.shape - 1)) * euler
      end

      def cumulative_function(x)
        upper = if as_rate?
                  self.rate * x.to_r
                else
                  x / self.scale.to_r
                end

        # left = 1.0 / Math.gamma(self.shape)
        # right = Math.lower_incomplete_gamma_function(self.shape, upper)
        # left * right
        Math.normalised_lower_incomplete_gamma_function(self.shape, upper)
      end
    end
  end
end
