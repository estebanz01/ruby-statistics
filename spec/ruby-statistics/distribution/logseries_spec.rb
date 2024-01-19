require 'spec_helper'

describe RubyStatistics::Distribution::LogSeries do
  describe '.density_function' do
    it 'is not defined for negative events' do
      expect(described_class.density_function(rand(-5..-1), rand)).to be_nil
    end

    it 'is not defined for zero events' do
      expect(described_class.density_function(0, rand)).to be_nil
    end

    it 'returns the expected result for the logarithmic distribution' do
      # Results extracted from http://calculator.vhex.net/calculator/probability/log-series-discrete-probability-mass
      # for x = 1, 2, 3, 4, 5 and p = 0.5

      results = [0.721348, 0.180337, 0.060112, 0.022542, 0.009017]

      1.upto(5) do |number|
        expect(described_class.density_function(number, 0.5).round(6)).to eq results[number - 1]
      end
    end
  end

  describe '.cumulative_function' do
    it 'is not defined for negative events' do
      expect(described_class.cumulative_function(rand(-5..-1), rand)).to be_nil
    end

    it 'is not defined for zero events' do
      expect(described_class.cumulative_function(0, rand)).to be_nil
    end

    it 'returns the expected result for the logarithmic distribution' do
      # Results extracted from http://calculator.vhex.net/calculator/probability/log-series-discrete-cumulative-distribution
      # for x = 1, 2, 3, 4, 5 and p = 0.5

      results = [0.721348, 0.901684, 0.961797, 0.984339, 0.993356]

      1.upto(5) do |number|
        expect(described_class.cumulative_function(number, 0.5).round(6)).to eq results[number - 1]
      end
    end
  end

  describe '.mode' do
    it 'returns 1.0' do
      expect(described_class.mode).to eq 1.0
    end
  end

  describe '.mean' do
    it 'returns the expected value for the logseries distribution' do
      p = rand
      expect(described_class.mean(p)).to eq ((-1.0 / Math.log(1.0 - p)) * (p / (1.0 - p)))
    end
  end

  describe '.variance' do
    it 'returns the expected value for the logseries distribution' do
      p = rand
      result = (-1.0 * p) * ((p + Math.log(1.0 - p)) / (((1.0 - p) ** 2) * (Math.log(1.0 - p) ** 2)))

      expect(described_class.variance(p)).to eq result
    end
  end
end
