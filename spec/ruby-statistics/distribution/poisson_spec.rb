require 'spec_helper'

describe RubyStatistics::Distribution::Poisson do
  describe '#probability_mass_function' do
    it 'returns the expected values using the poisson distribution' do
      results = [0.271, 0.271, 0.180, 0.090, 0.036]
      poisson = described_class.new(2) # lambda: 2

      (1..5).each_with_index do |number, index|
        expect(poisson.probability_mass_function(number).round(3)).to eq results[index]
      end
    end
  end

  describe '#cumulative_function' do
    it 'returns the expected values using the poisson distribution' do
      results = [0.406, 0.677, 0.857, 0.947, 0.983]
      poisson = described_class.new(2) # lambda: 2

      (1..5).each_with_index do |number, index|
        expect(poisson.cumulative_function(number).round(3)).to eq results[index]
      end
    end
  end

  describe '#mean' do
    it 'returns the lambda value specified at initialization time' do
      l = rand(10)
      poisson = described_class.new(l)

      expect(poisson.mean).to eq l
    end
  end

  describe '#variance' do
    it 'returns the lambda value specified at initialization time' do
      l = rand(10)
      poisson = described_class.new(l)

      expect(poisson.mean).to eq l
    end
  end
end
