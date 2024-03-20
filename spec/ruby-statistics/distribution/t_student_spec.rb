require 'spec_helper'

describe RubyStatistics::Distribution::TStudent do
  describe '#cumulative_function' do
    it 'returns the expected values for the T-Student distribution' do
      results = [0.7886751, 0.9082483, 0.9522670, 0.9714045, 0.9811252]
      t_student = described_class.new(2) # degrees of freedom: 2

      (1..5).each_with_index do |number, index|
        expect(t_student.cumulative_function(number).round(7)).to eq results[index]
      end
    end
  end

  describe '#density_function' do
    it 'is not defined for degrees of freedom less or equal to zero' do
      expect(described_class.new(rand(-5..0)).density_function(rand(10))).to be_nil
    end

    it 'returns the expected values for the T-Student distribution' do
      results = [0.2196798, 0.065090310, 0.01729258, 0.00512373, 0.00175744]

      (1..5).each_with_index do |number, index|
        t_student = described_class.new(5) # degrees of freedom: 5

        expect(t_student.density_function(number).round(8)).to eq results[index]
      end
    end
  end

  describe '#mean' do
    it 'returns zero if the degrees of freedom is greater than one' do
      expect(described_class.new(rand(2..10)).mean).to eq 0
    end

    it 'is not defined for degrees of freedom lesser or equal to one' do
      expect(described_class.new(rand(-5..1)).mean).to be_nil
    end
  end

  describe '#variance' do
    it 'returns the expected value for degrees of freedom greater than two' do
      v = rand(3..10)
      expected_variance = v/(v - 2.0)

      expect(described_class.new(v).variance).to eq expected_variance
    end

    it 'returns infinity for 1 < degrees of freedom <= 2' do
      v = rand((1.0001)..2) # Awful but true

      expect(described_class.new(v).variance).to eq Float::INFINITY
    end

    it 'is not defined for other values' do
      v = rand(-10..1)

      expect(described_class.new(v).variance).to be_nil
    end
  end

  describe '#random' do
    it 'generates a random number that follows a student-t distribution' do
      # T sample elements generated in R with degrees of freedom 4 and seed 100
      t_sample = [-0.55033048, -0.06690434, 0.11951965, -0.52008245, -1.11703451]
      random_sample = described_class.new(4).random(elements: 5, seed: 100)

      test = RubyStatistics::StatisticalTest::ChiSquaredTest.goodness_of_fit(0.01, t_sample, random_sample)

      expect(test[:null]).to be true
      expect(test[:alternative]).to be false
    end

    it 'does not generate a random sample that follows an uniform distribution' do
      pending 'random sample follows an uniform and t-student distribution'

      # Uniform sample elements generated in R with seed 100
      uniform_sample = [0.30776611, 0.25767250, 0.55232243, 0.05638315, 0.46854928]
      random_sample = described_class.new(4).random(elements: 5, seed: 100)

      test = RubyStatistics::StatisticalTest::ChiSquaredTest.goodness_of_fit(0.01, uniform_sample, random_sample)

      expect(test[:null]).to be false
      expect(test[:alternative]).to be true
    end
  end
end
