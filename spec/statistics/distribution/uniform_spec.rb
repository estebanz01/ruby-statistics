require 'spec_helper'

describe Statistics::Distribution::Uniform do
  describe '#density_function' do
    it 'returns the expected value for the uniform distribution' do
      left, right = 3.0, 4.0
      expected = 1/(right - left)

      expect(described_class.new(left, right).density_function(rand(3.0..4.0))).to eq expected
    end

    it 'returns zero when specified value does not belong to the Uniform distribution support' do
      left, right = rand(1..10), rand(1..10)
      uniform = described_class.new(left, right)

      expect(uniform.density_function(left - 1)).to eq 0
      expect(uniform.density_function(right + 1)).to eq 0
    end
  end

  describe '#cumulative_function' do
    it 'calculates the probability of the specified value for the uniform distribution' do
      results = [0.0, 0.0, 0.5, 1.0, 1.0]

      (1..5).each_with_index do |number, index|
        uniform = described_class.new(2, 4) # left: 2, right: 4

        expect(uniform.cumulative_function(number)).to eq results[index]
      end
    end

    it 'returns zero when the specified value is less than the left value' do
      expect(described_class.new(3,4).cumulative_function(2)).to eq 0
    end

    it 'returns one when the specified value is greater than the right value' do
      expect(described_class.new(4, 5).cumulative_function(6)).to eq 1
    end
  end

  describe '#mean' do
    it 'returns the expected mean for the uniform distribution' do
      left,right = rand(1..10), rand(1..10)

      expect(described_class.new(left, right).mean).to eq ((1/2.0) * (left + right))
    end
  end

  describe '#variance' do
    it 'returns the expected variance for the uniform distribution' do
      left,right = rand(1..10), rand(1..10)

      expect(described_class.new(left, right).variance).to eq ((1/12.0) * (right - left) ** 2)
    end
  end
end
