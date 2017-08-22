require 'spec_helper'

describe Statistics::Distribution::Binomial do
  describe '#probability_mass_function' do
    it 'is not defined for negative values' do
      expect(described_class.new(0, 0).probability_mass_function(rand(-10...0))).to be_nil
    end

    it 'is not defined for values greater than the number of defined trials' do
      k = rand(10)
      p = rand(0..1)
      expect(described_class.new(k, p).probability_mass_function(k + 1)).to be_nil
    end

    it 'returns the expected results for the binomial distribution' do
      results = [0.009765625, 0.0439453125, 0.117187500, 0.205078125, 0.246093750]
      binomial = described_class.new(10, 0.5) # Number of trials: 10, probability per trial: 0.5

      (1..5).each_with_index do |number, index|
        expect(binomial.probability_mass_function(number)).to eq results[index]
      end
    end
  end

  describe '#cumulative_function' do
    it 'is not defined for negative values' do
      expect(described_class.new(0, 0).cumulative_function(rand(-10...0))).to be_nil
    end

    it 'is not defined for values greater than the number of defined trials' do
      k = rand(10)
      p = rand(0..1)
      expect(described_class.new(k, p).cumulative_function(k + 1)).to be_nil
    end

    it 'returns the expected results for the binomial distribution' do
      results = [0.01074219, 0.05468750, 0.17187500, 0.37695313, 0.62304687]
      binomial = described_class.new(10, 0.5) # Number of trials: 10, probability per trial: 0.5

      (1..5).each_with_index do |number, index|
        expect(binomial.cumulative_function(number).round(8)).to eq results[index]
      end
    end
  end

  describe '#mean' do
    it 'returns the expected mean for the specified values' do
      n = rand(10)
      p = rand(0..1)

      expect(described_class.new(n, p).mean).to eq n * p
    end
  end

  describe '#variance' do
    it 'returns the expected variance for the specified values' do
      n = rand(10)
      p = rand(0..1)

      expect(described_class.new(n, p).variance).to eq (n * p) * (1 - p)
    end
  end

  describe '#mode' do
    # The test evaluator is: (number_of_trials + 1) * probability_per_trial
    it 'is the floor(test) when the test is zero o when it is a float' do
      n = rand(10)
      n = n.even? ? n - 1 : n
      p = (1/3.7) # To ensure that we always have a test with decimal places.
      test = (n + 1) * p
      expect(described_class.new(n, p).mode).to eq test.floor
    end

    context 'when the test is an integer and is located between {1, .., number_of_trials}' do
      it 'is the test value and test value minus one' do
        n, p = 11, 0.5
        test = (n + 1) * p
        expect(described_class.new(n, p).mode).to eq [test, test - 1]
      end
    end

    it 'is the number of trials when the probability per trial is 1.0' do
      n = rand(10)
      p = 1.0
      expect(described_class.new(n, p).mode).to eq n
    end
  end
end
