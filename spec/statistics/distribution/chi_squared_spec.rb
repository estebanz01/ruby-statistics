require 'spec_helper'

describe Statistics::Distribution::ChiSquared do
  describe '#density_function' do
    it' returns zero when the specified value is not defined in the chi-squared support domain' do
      expect(described_class.new(rand(1..10)).density_function(rand(-5..-1))).to eq 0
    end

    it 'calculates the expected value for the chi-squared distribution' do
      result = [0.242, 0.1038, 0.0514, 0.027, 0.0146]

      (1..5).each_with_index do |number, index|
        chi_sq = described_class.new(1) # 1 degree freedom

        expect(chi_sq.density_function(number).round(4)).to eq result[index]
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
