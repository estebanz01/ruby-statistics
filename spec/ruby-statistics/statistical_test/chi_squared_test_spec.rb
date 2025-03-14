require 'spec_helper'

describe RubyStatistics::StatisticalTest::ChiSquaredTest do
  describe '.chi_statistic' do
    # example ONE
    # explained here: https://www.thoughtco.com/chi-square-goodness-of-fit-test-example-3126382
    it 'returns an array with expected chi-squared statistic value following example ONE' do
      observed_counts = [212, 147, 103, 50, 46, 42]
      expected = 100
      result = described_class.chi_statistic(expected, observed_counts)
      expect(result[0]).to be_within(0.001).of(235.42)
    end

    it 'returns an array with the expected degrees of freedom following example ONE' do
      observed_counts = [212, 147, 103, 50, 46, 42]
      expected = 100
      result = described_class.chi_statistic(expected, observed_counts)
      degrees_of_freedom = observed_counts.size - 1

      expect(result[1]).to eq degrees_of_freedom
    end

    # Example two: chocolate colours
    # explained here: https://onlinecourses.science.psu.edu/stat414/book/export/html/228
    it 'returns an array with the expected chi-squared statistic value following example TWO' do
      observed = [224, 119, 130, 48, 59]
      expected = [232, 116, 116, 58, 58]

      result = described_class.chi_statistic(expected, observed)

      expect(result[0]).to be_within(0.001).of(3.784)
    end

    it 'returns an array with the expected degrees of freedom following example TWO' do
      observed = [224, 119, 130, 48, 59]
      expected = [232, 116, 116, 58, 58]

      result = described_class.chi_statistic(expected, observed)
      degrees_of_freedom = observed.size - 1

      expect(result[1]).to eq degrees_of_freedom
    end
  end

  describe '.goodness_of_fit' do
    it 'perform a goodness of fit test following example ONE' do
      observed_counts = [212, 147, 103, 50, 46, 42]
      expected = 100 # this is equal to [100, 100, 100, 100, 100, 100]
      result = described_class.goodness_of_fit(0.05, expected, observed_counts)


      # We cannot get exact p-values as it's dependant on the precision and the machine, therefore
      # we use a limit criteria defined by R in 4.4.1.
      # Here's the output for the same configuration:
      #   > observed <- c(212, 147, 103, 50, 46, 42)
      #   > expected <- c(100, 100, 100, 100, 100, 100)
      #   > chisq.test(observed, p = expected, rescale.p = TRUE)
      #	      Chi-squared test for given probabilities
      #
      #           data:  observed
      #           X-squared = 235.42, df = 5, p-value < 2.2e-16

      expect(result[:p_value]).to be <= 2.2e-16 # This matches the criteria used in R 4.4.1
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end

    it 'perform a goodness of fit test following example TWO' do
      observed = [224, 119, 130, 48, 59]
      expected = [232, 116, 116, 58, 58]

      result = described_class.goodness_of_fit(0.05, expected, observed)

      expect(result[:p_value]).to be_within(0.0001).of(0.4359)
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
    end

    # The following test is based on the numbers reported in https://github.com/estebanz01/ruby-statistics/issues/78
    # which give us a minimum test case scenario where the integral being solved with simpson's rule
    # uses zero iterations, raising errors.
    it 'performs a goodness of fit test with values that generates small chi statistics' do
      observed_counts = [481, 483, 482, 488, 478, 471, 477, 479, 475, 462]
      expected = 477

      result = {}

      expect do
        result = described_class.goodness_of_fit(0.01, expected, observed_counts)
      end.not_to raise_error

      expect(result[:p_value]).to be_within(0.0001).of(0.9995)
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
    end
  end
end
