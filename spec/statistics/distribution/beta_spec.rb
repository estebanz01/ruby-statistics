require 'spec_helper'

describe Statistics::Distribution::Beta do
  describe '.beta_function' do
    it 'returns 1 for the special case x = y = 1' do
      expect(described_class.beta_function(1, 1)).to eq 1
    end

    it 'Calculates the expected values for the beta function' do
      # TODO: Find a way to better test this instead of fixing some values.
      result = [1, 0.1667, 0.0333, 0.0071, 0.0016]

      (1..5).each_with_index do |number, index|
        expectation = described_class.beta_function(number, number).round(4)
        expect(expectation).to eq result[index]
      end
    end
  end

  describe '#density_function' do
    it 'returns zero when the value is not defined in the [0,1] interval' do
      expect(described_class.new(1,1).density_function(2)).to eq 0
      expect(described_class.new(1,1).density_function(-2)).to eq 0
    end

    it 'returns the expected values for the probability density function associated to the beta distribution' do
      # TODO: Find a way to better test this instead of fixing some values
      result = [0, 0.108, 0.384, 0.756, 1.152, 1.5]
      beta_distribution = described_class.new(3, 2) # Alpha = 3, Beta = 2

      [0, 0.1, 0.2, 0.3, 0.4, 0.5].each_with_index do |number, index|
        expect(beta_distribution.density_function(number).round(4)).to eq result[index]
      end
    end
  end

  describe '#mode' do
    it 'calculates the expected mode for the beta distribution' do
      alpha = rand(2..10)
      beta = rand(2..10)
      mode = (alpha.to_f - 1)/(alpha.to_f + beta.to_f - 2)

      expect(described_class.new(alpha, beta).mode).to eq (mode)
    end

    it 'is not defined for alpha, beta minor than or equal to 1' do
      alpha = rand(-3..1)
      beta = rand(-3..1)

      expect(described_class.new(alpha, beta).mode).to be_nil
    end
  end

  describe '#mean' do
    it 'calculates the expected mean for the beta distribution' do
      alpha = rand(-5..5)
      beta = rand(-5..5)

      expect(described_class.new(alpha, beta).mean).to eq alpha.to_f/(alpha.to_f + beta.to_f)
    end
  end
end
