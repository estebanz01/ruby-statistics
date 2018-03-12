module Statistics
  module StatisticalTest
    class TTest
      # Errors for Zero std
      class ZeroStdError < StandardError
        STD_ERROR_MSG = 'Standard deviation for the difference or group is zero. Please, reconsider sample contents'.freeze
      end

      # Perform a T-Test for one or two samples.
      # For the tails param, we need a symbol: :one_tail or :two_tail
      def self.perform(alpha, tails, *args)
        return if args.size < 2

        degrees_of_freedom = 0

        # If the comparison mean has been specified
        t_score = if args[0].is_a? Numeric
                    data_mean = args[1].mean
                    data_std = args[1].standard_deviation

                    raise ZeroStdError, ZeroStdError::STD_ERROR_MSG if data_std == 0

                    comparison_mean = args[0]
                    degrees_of_freedom = args[1].size

                    (data_mean - comparison_mean)/(data_std / Math.sqrt(args[1].size).to_f).to_f
                  else
                    sample_left_mean = args[0].mean
                    sample_left_variance = args[0].variance
                    sample_right_variance = args[1].variance
                    sample_right_mean = args[1].mean
                    degrees_of_freedom = args.flatten.size - 2

                    left_root = sample_left_variance/args[0].size.to_f
                    right_root = sample_right_variance/args[1].size.to_f

                    standard_error = Math.sqrt(left_root + right_root)

                    (sample_left_mean - sample_right_mean)/standard_error.to_f
                  end

        probability = Distribution::TStudent.new(degrees_of_freedom).cumulative_function(t_score)
        p_value = 1 - probability
        p_value *= 2 if tails == :two_tail

        { probability: probability,
          p_value: p_value,
          alpha: alpha,
          null: alpha < p_value,
          alternative: p_value <= alpha,
          confidence_level: 1 - alpha }
      end

      def self.paired_test(alpha, tails, left_group, right_group)
        raise StandardError, 'both samples are the same' if left_group == right_group

        # Handy snippet grabbed from https://stackoverflow.com/questions/2682411/ruby-sum-corresponding-members-of-two-or-more-arrays
        differences = [left_group, right_group].transpose.map { |value| value.reduce(:-) }

        degrees_of_freedom = differences.size - 1
        difference_std = differences.standard_deviation

        raise ZeroStdError, ZeroStdError::STD_ERROR_MSG if difference_std == 0

        down = difference_std/Math.sqrt(differences.size)

        t_score = (differences.mean - 0)/down.to_f

        probability = Distribution::TStudent.new(degrees_of_freedom).cumulative_function(t_score)

        p_value = 1 - probability
        p_value *= 2 if tails == :two_tail

        { probability: probability,
          p_value: p_value,
          alpha: alpha,
          null: alpha < p_value,
          alternative: p_value <= alpha,
          confidence_level: 1 - alpha }
      end
    end
  end
end
