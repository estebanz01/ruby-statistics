require 'spec_helper'

describe Statistics::Distribution::Normal do
  describe '#cumulative_function' do
    it 'returns the expected probabilites for the normal distribution' do
      results = [0.3445783, 0.4207403, 0.5000000, 0.5792597, 0.6554217]
      normal = described_class.new(3, 5) # mean 3, std 5

      (1..5).each_with_index do |number, index|
        expect(normal.cumulative_function(number).round(7)).to eq results[index]
      end
    end
  end

  describe '#density_function' do
    it 'returns the expected values for the normal distribution' do
      # TODO: Find a better way to test this.
      results = [0.0737, 0.0782, 0.0798, 0.0782, 0.0737]

      (1..5).each_with_index do |number, index|
        normal_distribution = described_class.new(3, 5) # mean = 3, std = 5

        expect(normal_distribution.density_function(number).round(4)).to eq results[index]
      end
    end
  end

  # To test random generation, we are going to use the Goodness-of-fit test
  # to validate if a sample fits a normal distribution.
  describe '#random' do
    it 'returns a pseudo random number that belongs to a normal distribution' do
      # Normal sample generated from R with mean 5, std 2.0 and seed 100
      alpha = 0.01
      normal_sample = [3.995615, 5.263062, 4.842166, 6.773570, 5.233943]
      random_sample = described_class.new(5.0, 2.0).random(elements: 5, seed: 100)

      test = Statistics::StatisticalTest::ChiSquaredTest.goodness_of_fit(alpha, normal_sample, random_sample)

      # Null hypothesis: Both samples belongs to the same distribution (normal in this case)
      # Alternative hypotesis: Each sample is generated with a different distribution.

      expect(test[:null]).to be true
      expect(test[:alternative]).to be false
    end

    it 'does not generate a random sample that follows an uniform distribution' do
      # Uniform sample elements generated in R with seed 100
      uniform_sample = [0.30776611, 0.25767250, 0.55232243, 0.05638315, 0.46854928]
      random_sample = described_class.new(5.0, 2.0).random(elements: 5, seed: 100)

      test = Statistics::StatisticalTest::ChiSquaredTest.goodness_of_fit(0.01, uniform_sample, random_sample)

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
      normal = described_class.new(5.0, 2.0)
      sample_1 = normal.random # 1 element by default
      sample_2 = normal.random(elements: 1)

      expect(sample_1).to be_a Numeric
      expect(sample_2).to be_a Numeric
    end
  end
end

describe Statistics::Distribution::StandardNormal do
  describe '#cumulative_function' do
    it 'returns the expected probabilities for the standard normal distribution' do
      results = [0.8413447, 0.9772499, 0.9986501, 0.9999683, 0.9999997]
      standard = described_class.new

      (1..5).each_with_index do |number, index|
        expect(standard.cumulative_function(number).round(7)).to eq results[index]
      end
    end
  end

  describe '#density_function' do
    it 'returns the expected values for the standard normal distribution with mean = 0, std = 1' do
      results = [0.24197, 0.05399, 0.00443, 0.00013, 0.00000]

      (1..5).each_with_index do |number, index|
        standard_distribution = described_class.new

        expect(standard_distribution.density_function(number).round(5)).to eq results[index]
      end
    end
  end
end
