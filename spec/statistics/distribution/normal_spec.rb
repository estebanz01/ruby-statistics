require 'spec_helper'

describe Statistics::Distribution::Normal do
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
end

describe Statistics::Distribution::StandardNormal do
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
