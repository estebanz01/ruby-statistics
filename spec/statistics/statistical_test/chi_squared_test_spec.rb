require 'spec_helper'
require 'matrix'

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

      expect(result[:p_value]).to eq -6.5358829459682966e-12
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

      expect(result[:p_value].round(4)).to eq(0.9995)
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
    end
  end

  describe '.calculate_expected_matr' do
    
    it 'calculate expected values for a 2*3 contingency table of observed values' do
      
      observed = Matrix[[388,51692],[119,45633],[271,40040]]
      expected = described_class.calculate_expected_matr(observed)

      expect(expected).to eq(Matrix[[(40518240/138143), (7153969200/138143)], [(35595056/138143), (6284723480/138143)], [(31361958/138143), (5537320515/138143)]])

    end

  end

  describe '.test_of_independence_matr' do

    it 'calculate test of independence for a 2*3 contingency table' do

      observed = Matrix[[388,51692],[119,45633],[271,40040]]
      alpha = 0.05

      result = {}

      expect do
        result = described_class.test_of_independence_matr(alpha, observed)
      end.not_to raise_error

      expect(result[:chi_score].round(4)).to eq(114.3600)
      expect(result[:p_value].round(4)).to eq(1.4690)
      expect(result[:df]).to eq(2)
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false

    end

  end


end
