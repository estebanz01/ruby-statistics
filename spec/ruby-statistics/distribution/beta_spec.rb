require 'spec_helper'

describe RubyStatistics::Distribution::Beta do
  describe '#cumulative_function' do
    it 'returns one for values greater than one' do
      expect(described_class.new(rand(10), rand(10)).cumulative_function(rand(2..10))).to eq 1
    end

    it 'is not defined for values less than zero' do
      expect(described_class.new(rand(10), rand(10)).cumulative_function(rand(-5...0))).to be_nil
    end

    it 'returns the expected values for the beta distribution' do
      result = [0.0523, 0.1808, 0.3483, 0.5248, 0.6875]
      beta_distribution = described_class.new(2, 3) # alpha 2, beta 3

      [0.1, 0.2, 0.3, 0.4, 0.5].each_with_index do |number, index|
        expect(beta_distribution.cumulative_function(number)).to be_within(0.0001).of(result[index])
      end
    end
  end

  describe '#density_function' do
    it 'returns zero when the value is not defined in the [0,1] interval' do
      expect(described_class.new(1,1).density_function(2)).to eq 0
      expect(described_class.new(1,1).density_function(-2)).to eq 0
    end

    it 'returns the expected values for the probability density function associated to the beta distribution' do
      # TODO: Find a way to better test this instead of fixing some values
      result = [0, 0.108, 0.384, 0.756, 1.152, 1.5]
      beta_distribution = described_class.new(3, 2) # Alpha = 3, Beta = 2

      [0, 0.1, 0.2, 0.3, 0.4, 0.5].each_with_index do |number, index|
        expect(beta_distribution.density_function(number)).to be_within(0.0001).of(result[index])
      end
    end
  end

  describe '#mode' do
    it 'calculates the expected mode for the beta distribution' do
      alpha = rand(2..10)
      beta = rand(2..10)
      mode = (alpha.to_f - 1)/(alpha.to_f + beta.to_f - 2)

      expect(described_class.new(alpha, beta).mode).to eq (mode)
    end

    it 'is not defined for alpha, beta minor than or equal to 1' do
      alpha = rand(-3..1)
      beta = rand(-3..1)

      expect(described_class.new(alpha, beta).mode).to be_nil
    end
  end

  describe '#mean' do
    it 'returns nil if alpha and beta is zero' do
      alpha = 0
      beta = 0

      expect(described_class.new(alpha, beta).mean).to be_nil
    end

    it 'returns nil if the sum of alpha and beta is zero' do
      alpha = -1
      beta = 1

      expect(described_class.new(alpha, beta).mean).to be_nil
    end

    it 'calculates the expected mean for the beta distribution' do
      alpha = rand(-5..5)
      beta = rand(-5..5)

      if alpha + beta == 0 # To avoid NaN results.
        alpha = 1
        beta = 1
      end

      expect(described_class.new(alpha, beta).mean).to eq alpha.to_f/(alpha.to_f + beta.to_f)
    end
  end
end
