module Statistics
  module StatisticalTest
    class KolmogorovSmirnovTest
      # Common alpha, and critical D are calculated following formulas from: https://en.wikipedia.org/wiki/Kolmogorov%E2%80%93Smirnov_test#Two-sample_Kolmogorov%E2%80%93Smirnov_test
      def self.two_samples(group_one:, group_two:, alpha: 0.05)
        samples = group_one + group_two # We can use unbalaced group samples

        ecdf_one = Distribution::Empirical.new(samples: group_one)
        ecdf_two = Distribution::Empirical.new(samples: group_two)

        d_max = samples.sort.map do |sample|
          d1 = ecdf_one.cumulative_function(x: sample)
          d2 = ecdf_two.cumulative_function(x: sample)

          (d1 - d2).abs
        end.max

        # TODO: Validate calculation of Common alpha.
        common_alpha = Math.sqrt((-0.5 * Math.log(alpha)))
        radicand = (group_one.size + group_two.size) / (group_one.size * group_two.size).to_f

        critical_d = common_alpha * Math.sqrt(radicand)

        # We are unable to calculate the p_value, because we don't have the Kolmogorov distribution
        # defined. We reject the null hypotesis if Dmax is > than Dcritical.
        { d_max: d_max,
          d_critical: critical_d,
          alpha: alpha,
          null: d_max <= critical_d,
          alternative: d_max > critical_d,
          confidence_level: 1 - alpha }
      end
    end

    KSTest = KolmogorovSmirnovTest # Alias
  end
end
