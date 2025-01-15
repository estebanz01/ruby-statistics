require 'spec_helper'

describe RubyStatistics::Distribution::ChiSquared do
  describe '#cumulative_function' do
    it 'returns the expected probabilities for the chi-squared distribution' do
      results = [0.0374, 0.1509, 0.3, 0.4506, 0.5841]
      chi_sq = described_class.new(5) # 5 degrees of freedom

      (1..5).each_with_index do |number, index|
        expect(chi_sq.cumulative_function(number)).to be_within(0.0001).of(results[index])
      end
    end

    context 'With degrees of freedom from 1 to 30' do
      it 'returns the expected probabilities for the chi-squared distribution compared to a table' do
        # Values retrieved from the following table provided by the University of Arizona.
        # https://math.arizona.edu/~jwatkins/chi-square-table.pdf
        alpha = 0.100
        # Each index represents the degrees of freedom
        values = [
          2.706, 4.605, 6.251, 7.779, 9.236, 10.645, 12.017, 13.362, 14.684, 15.987, 17.275,
          18.549, 19.812, 21.064, 22.307, 23.542, 24.769, 25.989, 27.204, 28.412, 29.615,
          30.813, 32.007, 33.196, 34.382, 35.563, 36.741, 37.916, 39.087, 40.256
        ]

        values.each_with_index do |p, index|
          result = 1.0 - described_class.new(index + 1).cumulative_function(p)
          expect(result).to be_within(0.0001).of(alpha)
        end
      end
    end

    context 'With degrees of freedom from 40 to 100, with a 10 unit increment' do
      it 'returns the expected probabilities for the chi-squared distribution compared to a table' do
        # Values retrieved from the following table provided by the University of Arizona.
        # https://math.arizona.edu/~jwatkins/chi-square-table.pdf
        alpha = 0.100

        # Each index represents the degrees of freedom
        values = [51.805, 63.167, 74.397, 85.527, 96.578, 107.565, 118.498]

        values.each_with_index do |p, index|
          df = (index + 1) * 10 + 30 # we start on 40
          result = 1.0 - described_class.new(df).cumulative_function(p)
          expect(result).to be_within(0.0001).of(alpha)
        end
      end
    end

    context 'when the degrees of freedom is 2 for the chi-squared distribution' do
      it 'performs the probability calculation using the special case instead' do
        # Results gathered from R 4.0.3
        # # > pchisq(1:10, df = 2)
        # # [1] 0.3935 0.6321 0.7769 0.8647 0.9179 0.9502 0.9698 0.9817 0.9889 0.9933
        results = [0.3935, 0.6321, 0.7769, 0.8647, 0.9179, 0.9502, 0.9698, 0.9817, 0.9889, 0.9933]
        chi_sq = described_class.new(2)

        (1..10).each_with_index do |number, index|
          expect(chi_sq.cumulative_function(number)).to be_within(0.0001).of(results[index])
        end
      end
    end
  end

  describe '#density_function' do
    it' returns zero when the specified value is not defined in the chi-squared support domain' do
      expect(described_class.new(rand(1..10)).density_function(rand(-5..-1))).to eq 0
    end

    it 'calculates the expected value for the chi-squared distribution' do
      result = [0.242, 0.1038, 0.0514, 0.027, 0.0146]

      (1..5).each_with_index do |number, index|
        chi_sq = described_class.new(1) # 1 degree freedom

        expect(chi_sq.density_function(number)).to be_within(0.0001).of(result[index])
      end
    end
  end

  describe '#mode' do
    it 'returns the specific mode for the chi-squared distribution' do
      (1..10).each do |k|
        chi_sq = described_class.new(k)

        expect(chi_sq.mode).to eq [k - 2, 0].max
      end
    end
  end

  describe '#variance' do
    it 'returns the specific variance for the chi-squared distribution' do
      (1..10).each do |k|
        chi_sq = described_class.new(k)

        expect(chi_sq.variance).to eq (2 * k)
      end
    end
  end
end
