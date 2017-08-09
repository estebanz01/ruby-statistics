require 'spec_helper'

describe Statistics::Distribution::TStudent do
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
end
