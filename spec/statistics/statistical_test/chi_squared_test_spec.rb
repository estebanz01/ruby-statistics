require 'spec_helper'

describe Statistics::StatisticalTest::ChiSquaredTest do
  describe '.chi_statistic' do
    # example ONE
    # explained here: https://www.thoughtco.com/chi-square-goodness-of-fit-test-example-3126382
    it 'returns an array with expected chi-squared statistic value following example ONE' do
      observed_counts = [212, 147, 103, 50, 46, 42]
      expected = 100
      result = described_class.chi_statistic(expected, observed_counts)
      expect(result[0].round(3)).to eq 235.42
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

      expect(result[0].round(3)).to eq 3.784
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

      expect(result[:p_value]).to eq -6.509237593377293e-12
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end

    it 'perform a goodness of fit test following example TWO' do
      observed = [224, 119, 130, 48, 59]
      expected = [232, 116, 116, 58, 58]

      result = described_class.goodness_of_fit(0.05, expected, observed)

      expect(result[:p_value].round(4)).to eq 0.4359
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
    end
  end
end
