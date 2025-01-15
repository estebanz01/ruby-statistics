require 'spec_helper'

describe RubyStatistics::Distribution::Weibull do
  describe '#density_function' do
    it 'returns the expected density for the weibull distribution' do
      results = [0.04614827, 0.16546817, 0.27667238, 0.27590958, 0.16620722]

      (1..5).each_with_index do |number, index|
        weibull = described_class.new(3, 4) # shape: 3, scale: 4

        expect(weibull.density_function(number)).to be_within(0.00000001).of(results[index])
      end
    end

    it 'returns zero for values less than zero' do
      expect(described_class.new(3, 4).density_function(rand(-10...0))).to eq 0
    end

    it 'is not defined for shape and scale values less or equal than zero' do
      expect(described_class.new(rand(-5..0), rand(-5..0)).density_function(rand(10))).to be_nil
    end
  end

  describe '#cumulative_function' do
    it 'returns the expected probability for the weibull distribution using the specified value' do
      results = [0.1051607, 0.3588196, 0.6321206, 0.8309867, 0.9378235]

      (1..5).each_with_index do |number, index|
        weibull = described_class.new(2, 3) # shape: 2, scale: 3

        expect(weibull.cumulative_function(number)).to be_within(0.0000001).of(results[index])
      end
    end

    it 'returns zero for specified vaules less or equal than zero' do
      expect(described_class.new(2, 3).cumulative_function(rand(-5..0))).to eq 0
    end
  end

  describe '#mean' do
    it 'returns the expected mean for the weibull distribution' do
      shape = rand(1..10).to_f
      scale = rand(1..10).to_f

      expected = scale * Math.gamma(1 + (1/shape))
      expect(described_class.new(shape, scale).mean).to eq expected
    end
  end

  describe '#mode' do
    it 'returns zero if the shape is less or equal than one' do
      expect(described_class.new(rand(-5..1),rand(10)).mode).to eq 0
    end

    it 'returns the expected mode for the weibull distribution' do
      shape = rand(2..10).to_f
      scale = rand(1..10).to_f

      expected = scale * (((shape - 1)/shape) ** (1/shape))

      expect(described_class.new(shape, scale).mode).to eq expected
    end
  end

  describe '#variance' do
    it 'returns the expected variance for the weibull distribution' do
      scale, shape = rand(1..10).to_f, rand(1..10).to_f
      left = Math.gamma(1 + (2/shape))
      right = Math.gamma(1 + (1/shape)) ** 2

      expected = (scale ** 2) * (left - right)

      expect(described_class.new(shape, scale).variance).to eq expected
    end
  end

  # To test random generation, we are going to use the Goodness-of-fit test
  # to validate if a sample fits a weibull distribution.
  describe '#random' do
    it 'returns a pseudo random number that belongs to a weibull distribution' do
      # Weibull sample generated from R with shape (k) 5, scale (lambda) 2.0 and seed 100
      alpha = 0.01
      weibull_sample = [2.066758, 2.125623, 1.801906, 2.470445, 1.892243]
      random_sample = described_class.new(5.0, 2.0).random(elements: 5, seed: 100)

      test = RubyStatistics::StatisticalTest::ChiSquaredTest.goodness_of_fit(alpha, weibull_sample, random_sample)

      # Null hypothesis: Both samples belongs to the same distribution (weibull in this case)
      # Alternative hypotesis: Each sample is generated with a different distribution.

      expect(test[:null]).to be true
      expect(test[:alternative]).to be false
    end

    it 'does not generate a random sample that follows an uniform distribution' do
      # Uniform sample elements generated in R with seed 100
      uniform_sample = [0.30776611, 0.25767250, 0.55232243, 0.05638315, 0.46854928]
      random_sample = described_class.new(5.0, 2.0).random(elements: 5, seed: 100)

      test = RubyStatistics::StatisticalTest::ChiSquaredTest.goodness_of_fit(0.01, uniform_sample, random_sample)

      expect(test[:null]).to be false
      expect(test[:alternative]).to be true
    end

    it 'generates the specified number of random elements and store it into an array' do
      elements = rand(2..5)
      sample = described_class.new(5.0, 2.0).random(elements: elements)

      expect(sample).to be_a Array
      expect(sample.size).to eq elements
    end

    it 'returns a single random number when only one element is required' do
      weibull = described_class.new(5.0, 2.0)
      sample_1 = weibull.random # 1 element by default
      sample_2 = weibull.random(elements: 1)

      expect(sample_1).to be_a Numeric
      expect(sample_2).to be_a Numeric
    end
  end
end
