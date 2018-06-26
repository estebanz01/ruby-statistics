require 'spec_helper'

describe Statistics::Distribution::Bernoulli do
  describe '.density_function' do
    it 'is not defined when the outcome is different from zero or one' do
      expect(described_class.density_function(rand(2..10), rand)).to be_nil
      expect(described_class.density_function(rand(-5..-1), rand)).to be_nil
    end

    it 'returns the expected value when the outcome is zero' do
      p = rand
      expect(described_class.density_function(0, p)).to eq (1.0 - p)
    end

    it 'returns the expected value when the outcome is one' do
      p = rand
      expect(described_class.density_function(1, p)).to eq p
    end
  end

  describe '.cumulative_function' do
    it 'is not defined when the outcome is different from zero or one' do
      expect(described_class.cumulative_function(rand(2..10), rand)).to be_nil
      expect(described_class.density_function(rand(-5..-1), rand)).to be_nil
    end

    it 'returns the expected value when the outcome is zero' do
      p = rand
      expect(described_class.cumulative_function(0, p)).to eq (1.0 - p)
    end

    it 'returns the expected value when the outcome is one' do
      expect(described_class.cumulative_function(1, rand)).to eq 1.0
    end
  end

  describe '.variance' do
    it 'returns the expected value for the bernoulli distribution' do
      p = rand

      expect(described_class.variance(p)).to eq p * (1.0 - p)
    end
  end

  describe '.skewness' do
    it 'returns the expected value for the bernoulli distribution' do
      p = rand
      expected_value = (1.0 - 2.0*p).to_f / Math.sqrt(p * (1.0 - p))

      expect(described_class.skewness(p)).to eq expected_value
    end
  end

  describe '.kurtosis' do
    it 'returns the expected value for the bernoulli distribution' do
      p = rand
      expected_value = (6.0 * (p ** 2) - (6 * p) + 1) / (p * (1.0 - p))

      expect(described_class.kurtosis(p)).to eq expected_value
    end
  end
end
