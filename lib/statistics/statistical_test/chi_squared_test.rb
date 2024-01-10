module Statistics
  module StatisticalTest
    class ChiSquaredTest

      require 'matrix'

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
      # tables (short: ct) of the type
      #
      #      A   B
      # X   20  18
      # Y    7  35
      #
      # They have been tested using 2x2 and 3x3 tables.
      #
      def self.test_of_independence_matr(alpha, observed_matr)
        expected_matr = calculate_expected_matr(observed_matr)
        df = (observed_matr.row_size - 1) * (observed_matr.column_size - 1)
        chi_score = chi_statistic_matr(observed_matr, expected_matr)
        probability = 1.0 - Statistics::Distribution::ChiSquared.new(df).cumulative_function(chi_score)
        p_value = 1.0 - probability
    
        {
          chi_score: chi_score,
          df: df,
          probability: probability,
          p_value: p_value,
          alpha: alpha,
          null: alpha < p_value,
          alternative: p_value <= alpha,
          confidence_level: 1 - alpha,
          expected: expected_matr
        }
      end
      
      # For a contingency table of observed values, calculate the expected values
      def self.calculate_expected_matr(observed_matr)
        row_sums = observed_matr.row_vectors.map { |row| row.to_a.sum.to_r }
        col_sums = observed_matr.column_vectors.map { |col| col.to_a.sum.to_r }
        total_sum = row_sums.sum
        
        # create a mutable array from the Matrix of observed values
        # so we have a 'template' for our Matrx of expected values
        expected = observed_matr.to_a
        # calculate the expected values
        observed_matr.each_with_index do |i, row, col|
          expected[row][col] = (row_sums[row] * col_sums[col]) / total_sum
        end
        Matrix.rows(expected)
      end
    
      private

      def self.chi_statistic_matr(observed_matr, expected_matr)
        sum = 0.0
        observed_matr.each_with_index do |i, row, col|
            sum += (observed_matr[row, col] - expected_matr[row, col])**2 / expected_matr[row, col]
        end
        sum
      end
    end
  end
end
