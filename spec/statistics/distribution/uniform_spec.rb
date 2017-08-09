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
