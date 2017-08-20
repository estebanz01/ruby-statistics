require 'spec_helper'

describe Math do
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

  describe '.incomplete_beta_function' do
    it 'calculates the expected values for the incomplete beta function' do
      # The last 2 values:
      # For 9 is 0.9999979537560903519733 which is rounding to 1.0
      # For 10 is 1.0
      results = [0.19, 0.1808, 0.2557, 0.4059, 0.6230, 0.8418, 0.9685, 0.9985, 1.0, 1.0]

      (1..10).each_with_index do |number, index|
        expect(described_class.incomplete_beta_function(number/10.0, number, number + 1).round(4))
          .to eq results[index]
      end
    end
  end
end
