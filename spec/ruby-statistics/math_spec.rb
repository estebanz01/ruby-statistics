require 'spec_helper'

describe Math do
  describe '.factorial' do
    it 'is not defined for numbers less than zero' do
      expect(described_class.factorial(rand(-100...0))).to be_nil
    end

    it 'returns one for zero or one' do
      expect(described_class.factorial(0)).to eq 1
      expect(described_class.factorial(1)).to eq 1
    end

    it 'calculates the correct factorial for the specified number' do
      expect(described_class.factorial(2)).to eq 2
      expect(described_class.factorial(3)).to eq 6
      expect(described_class.factorial(4)).to eq 24
      expect(described_class.factorial(5)).to eq 120
    end

    it 'truncates the decimal numbers and calculates the factorial for the real part' do
      expect(described_class.factorial(5.4535459823483432434)).to eq 120
    end
  end

  describe '.permutation' do
    it 'calculates the possible permutations of k objects from a set of n elements' do
      expect(described_class.permutation(15,4)).to eq 32760
      expect(described_class.permutation(16, 3)).to eq 3360 # 16 balls, choose 3.
      expect(described_class.permutation(10, 2)).to eq 90 # 10 people to select 1th and 2nd place.
    end
  end

  describe '.combination' do
    it 'calculates the possible combinations of k object from a set of n elements' do
      expect(described_class.combination(16, 3)).to eq 560 # Order 16 balls in 3 ways.
      expect(described_class.combination(5, 3)).to eq 10 # How to choose 3 people out of 5.
      expect(described_class.combination(12, 5)).to eq 792 # How to choose 5 games out of 12.
    end
  end

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

      expect(function_a.floor).to eq res_a.floor
      expect(function_b.floor).to eq res_b.floor
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

    it "uses the simpson's rule with iterations bigger than 10_000 when upper is 0.0 < x < 1.0" do
      lower = 0
      upper = rand(0.01..0.99)
      iteration = 10_000 * (1 + upper.round(1))

      expect(described_class).to receive(:simpson_rule).with(lower, upper.to_r, iteration)

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

    # The following context is based on the numbers reported in https://github.com/estebanz01/ruby-statistics/issues/78
    # which give us a minimum test case scenario where the integral being solved with simpson's rule
    # uses zero iterations, raising errors.
    context 'When X for the lower incomplete gamma function is rounded to zero' do
      let(:s_parameter) { 4.5 }
      let(:x) { (52/53).to_r }

      it 'does not try to perform a division by zero' do
        expect do
          described_class.lower_incomplete_gamma_function(s_parameter, x)
        end.not_to raise_error
      end

      it "tries to solve the function using simpson's rule with at least 100_000 iterations" do
        expect(described_class).to receive(:simpson_rule).with(0, x, 100_000)

        described_class.lower_incomplete_gamma_function(s_parameter, x)
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
