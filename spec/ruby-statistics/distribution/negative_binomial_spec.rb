require 'spec_helper'

describe RubyStatistics::Distribution::NegativeBinomial do
  describe '#probability_mass_function' do
    it 'is not defined for negative values' do
      expect(described_class.new(0, 0).probability_mass_function(rand(-10...0))).to be_nil
    end

    it 'is not defined for values greater than the number of defined failures before success' do
      k = rand(10)
      p = rand
      expect(described_class.new(k, p).probability_mass_function(k + 1)).to be_nil
    end

    it 'returns the expected results for the negative binomial distribution' do
      # Results from R:
      # dnbinom(c(1,2,3,4,5), size = 10, prob = 0.5)
      # [1] 0.004882812 0.013427734 0.026855469 0.043640137 0.061096191

      results = [0.00488281, 0.01342773, 0.02685547, 0.04364014, 0.06109619]
      binomial = described_class.new(10, 0.5) # Number of failures: 10, probability per trial: 0.5

      (1..5).each_with_index do |number, index|
        expect(binomial.probability_mass_function(number).round(8)).to eq results[index]
      end
    end
  end

  describe '#cumulative_function' do
    it 'is not defined for negative values' do
      expect(described_class.new(0, 0).cumulative_function(rand(-10...0))).to be_nil
    end

    it 'is not defined for values greater than the number of defined failures before success' do
      k = rand(10)
      p = rand
      expect(described_class.new(k, p).cumulative_function(k + 1)).to be_nil
    end

    it 'returns the expected results for the negative binomial distribution' do
      # Results from R:
      # pnbinom(c(1,2,3,4,5), size = 10, prob = 0.5)
      # [1] 0.005859375 0.019287109 0.046142578 0.089782715 0.150878906

      results = [0.005859375, 0.019287109, 0.046142578, 0.089782715, 0.150878906]
      binomial = described_class.new(10, 0.5) # Number of trials: 10, probability per trial: 0.5

      (1..5).each_with_index do |number, index|
        expect(binomial.cumulative_function(number).round(9)).to eq results[index]
      end
    end
  end

  describe '#mean' do
    it 'returns the expected mean for the specified values' do
      n = rand(10)
      p = rand

      expect(described_class.new(n, p).mean).to eq (p * n)/(1 - p).to_f
    end
  end

  describe '#variance' do
    it 'returns the expected variance for the specified values' do
      n = rand(10)
      p = rand

      expect(described_class.new(n, p).variance).to eq (p * n)/((1 - p) ** 2).to_f
    end
  end

  describe '#mode' do
    it 'returns 0.0 if the number of failures before a success is less or equal than one' do
      n = rand(-10..1)
      p = rand

      expect(described_class.new(n, p).mode).to eq 0.0
    end

    it 'calculates the mode if the number of failures before a success is greather than one' do
      n = 2 + rand(10)
      p = rand

      expect(described_class.new(n, p).mode).to eq ((p * (n - 1))/(1 - p).to_f).floor
    end
  end

  describe '#skewness' do
    it 'calculates the skewness for the negative binomial distribution' do
      n = rand(10)
      p = rand

      expect(described_class.new(n, p).skewness).to eq ((1 + p).to_f / Math.sqrt(p * n))
    end
  end
end
