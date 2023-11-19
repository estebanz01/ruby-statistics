module Statistics
  module StatisticalTest
    class ChiSquaredTest
      def self.chi_statistic(expected, observed)
        # If the expected is a number, we asumme that all expected observations
        # has the same probability to occur, hence we expect to see the same number
        # of expected observations per each observed value
        statistic = if expected.is_a? Numeric
                      observed.reduce(0) do |memo, observed_value|
                        up = (observed_value - expected) ** 2
                        memo += (up/expected.to_r)
                      end
                    else
                      expected.each_with_index.reduce(0) do |memo, (expected_value, index)|
                        up = (observed[index] - expected_value) ** 2
                        memo += (up/expected_value.to_r)
                      end
                    end

          [statistic, observed.size - 1]
      end

      def self.goodness_of_fit(alpha, expected, observed)
        chi_score, df = *self.chi_statistic(expected, observed) # Splat array result

        return if chi_score.nil? || df.nil?

        probability = Distribution::ChiSquared.new(df).cumulative_function(chi_score)
        p_value = 1 - probability

        # According to https://stats.stackexchange.com/questions/29158/do-you-reject-the-null-hypothesis-when-p-alpha-or-p-leq-alpha
        # We can assume that if p_value <= alpha, we can safely reject the null hypothesis, ie. accept the alternative hypothesis.
        { probability: probability,
          p_value: p_value,
          alpha: alpha,
          null: alpha < p_value,
          alternative: p_value <= alpha,
          confidence_level: 1 - alpha }
      end

      # The following three functions serve to calculate a test of independence for contingency
      # tables of the type
      #
      #      A   B
      # X   20  18
      # Y    7  35
      #
      # They have been tested using 2x2 and 3x3 tables.
      #
      def self.test_of_independence(alpha, observed)
        expected = calculate_expected(observed)
        df = (observed.size - 1) * (observed.transpose.size - 1)
        chi_score = calculate_chi_score(observed, expected)
        probability = 1.0 - Statistics::Distribution::ChiSquared.new(df).cumulative_function(chi_score)
        p_value = 1.0 - probability
    
        {
          chi_score: chi_score,
          df: df,
          probability: probability,
          p_value: p_value,
          alpha: alpha,
          #null: alpha < p_value,
          #alternative: p_value <= alpha,
          confidence_level: 1 - alpha,
          expected: expected
        }
      end
      
      # For a contingency table of observed values, calculate the expected values
      def self.calculate_expected(observed)
        row_sums = observed.map { |row| row.sum.to_f }
        col_sums = observed.transpose.map { |col| col.sum.to_f }
        total_sum = row_sums.sum
    
        expected = observed.map.with_index { |row, i|
          row.map.with_index { |obs, j|
            (row_sums[i] * col_sums[j]) / total_sum
          }
        }
        expected
      end
    
      def self.calculate_chi_score(observed, expected)
        sum = 0.0
        observed.size.times { |i|
          observed[i].size.times { |j|
            sum += ((observed[i])[j] - (expected[i])[j])**2 / (expected[i])[j]
          }
        }
        sum
      end
    end
  end
end
