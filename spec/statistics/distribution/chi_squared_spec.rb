require 'spec_helper'

describe Statistics::Distribution::ChiSquared do
  describe '.simpson_rule' do
    it 'approximates a solution in the [a,b] interval for the integral of the specified function' do
      lower = rand(10)
      upper = rand(11..20)

      function_a = described_class.simpson_rule(lower, upper, 10_000) do |x|
        x ** 2
      end

      function_b = described_class.simpson_rule(lower, upper, 10_000) do |x|
        Math.sin(x)
      end

      res_a = ((upper ** 3)/3.0) - ((lower ** 3)/3.0) # Integral of x^2
      res_b = -Math.cos(upper) + Math.cos(lower) # Integral of sin(x)

      expect(function_a.round).to eq res_a.round
      expect(function_b.round).to eq res_b.round
    end

    it 'is not defined when the iterations are not even numbers' do
      expect(
        described_class.simpson_rule(1, 2, 3) { |x| x }
      ).to be_nil
    end
  end

  describe '.lower_incomplete_gamma_function' do
    it "solves the function using the simpson's rule" do
      lower = 0
      upper = rand(1..5)
      iteration = 10_000 * upper

      expect(described_class).to receive(:simpson_rule).with(lower, upper, iteration)
      described_class.lower_incomplete_gamma_function(lower, upper)
    end

    it 'returns the expected calculation' do
      results = [0.6322, 0.594, 1.1536, 3.3992, 13.4283]

      (1..5).each_with_index do |number, index|
        expect(
          described_class.lower_incomplete_gamma_function(number, number).round(4)
        ).to eq results[index]
      end
    end
  end

  describe '#cumulative_function' do
    it 'returns the expected probabilities for the chi-squared distribution' do
      results = [0.0374, 0.1509, 0.3, 0.4506, 0.5841]
      chi_sq = described_class.new(5) # 5 degrees of freedom

      (1..5).each_with_index do |number, index|
        expect(chi_sq.cumulative_function(number).round(4)).to eq results[index]
      end
    end
  end

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
