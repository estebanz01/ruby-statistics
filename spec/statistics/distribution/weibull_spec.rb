require 'spec_helper'

describe Statistics::Distribution::Weibull do
  describe '#density_function' do
    it 'returns the expected density for the weibull distribution' do
      results = [0.04614827, 0.16546817, 0.27667238, 0.27590958, 0.16620722]

      (1..5).each_with_index do |number, index|
        weibull = described_class.new(3, 4) # shape: 3, scale: 4

        expect(weibull.density_function(number).round(8)).to eq results[index]
      end
    end

    it 'returns zero for values less than zero' do
      expect(described_class.new(3, 4).density_function(rand(-10...0))).to eq 0
    end

    it 'is not defined for shape and scale values less or equal than zero' do
      expect(described_class.new(rand(-5..0), rand(-5..0)).density_function(rand(10))).to be_nil
    end
  end

  describe '#cumulative_function' do
    it 'returns the expected probability for the weibull distribution using the specified value' do
      results = [0.1051607, 0.3588196, 0.6321206, 0.8309867, 0.9378235]

      (1..5).each_with_index do |number, index|
        weibull = described_class.new(2, 3) # shape: 2, scale: 3

        expect(weibull.cumulative_function(number).round(7)).to eq results[index]
      end
    end

    it 'returns zero for specified vaules less or equal than zero' do
      expect(described_class.new(2, 3).cumulative_function(rand(-5..0))).to eq 0
    end
  end

  describe '#mean' do
    it 'returns the expected mean for the weibull distribution' do
      shape = rand(1..10).to_f
      scale = rand(1..10).to_f

      expected = scale * Math.gamma(1 + (1/shape))
      expect(described_class.new(shape, scale).mean).to eq expected
    end
  end

  describe '#mode' do
    it 'returns zero if the shape is less or equal than one' do
      expect(described_class.new(rand(-5..1),rand(10)).mode).to eq 0
    end

    it 'returns the expected mode for the weibull distribution' do
      shape = rand(2..10).to_f
      scale = rand(1..10).to_f

      expected = scale * (((shape - 1)/shape) ** (1/shape))

      expect(described_class.new(shape, scale).mode).to eq expected
    end
  end

  describe '#variance' do
    it 'returns the expected variance for the weibull distribution' do
      scale, shape = rand(1..10).to_f, rand(1..10).to_f
      left = Math.gamma(1 + (2/shape))
      right = Math.gamma(1 + (1/shape)) ** 2

      expected = scale * (left - right)

      expect(described_class.new(shape, scale).variance).to eq expected
    end
  end
end
