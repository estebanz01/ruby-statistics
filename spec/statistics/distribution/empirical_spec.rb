require 'spec_helper'

describe Statistics::Distribution::Empirical do
  describe '#cumulative_function' do
    it 'calculates the CDF for the specified value using a group of samples' do
      # Result in R
      # > cdf <- ecdf(c(1,2,3,4,5,6,7,8,9,0))
      # > cdf(7)
      # [1] 0.8
      samples = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]
      x = 7
      x_prob = 0.8

      expect(described_class.new(samples: samples).cumulative_function(x: x)).to eq x_prob
    end
  end
end
