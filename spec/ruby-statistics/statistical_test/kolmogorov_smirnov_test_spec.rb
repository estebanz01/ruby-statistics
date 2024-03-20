require 'spec_helper'

describe RubyStatistics::StatisticalTest::KolmogorovSmirnovTest do
  describe 'KSTest' do
    it 'defines KSTest as an alias for the KolmogorovSmirnovTest class name' do
      expect(RubyStatistics::StatisticalTest::KSTest).to be_a(Class)
      expect(RubyStatistics::StatisticalTest::KSTest).to eq described_class
    end
  end

  describe '.two_samples' do
    it 'computes a two-sided Kolmogorov-Smirnov test for two samples, following example ONE' do
      # Data extracted from http://www.stats.ox.ac.uk/~massa/Lecture%2013.pdf
      # calculation in R:
      # > ks.test(c(1.2,1.4,1.9,3.7,4.4,4.8,9.7,17.3,21.1,28.4), c(5.6,6.5,6.6,6.9,9.2,10.4,10.6,19.3))
      #
      #   Two-sample Kolmogorov-Smirnov test
      #
      #   D = 0.6, p-value = 0.04987
      #   alternative hypothesis: two-sided

      group_one = [1.2, 1.4, 1.9, 3.7, 4.4, 4.8, 9.7, 17.3, 21.1, 28.4]
      group_two = [5.6, 6.5, 6.6, 6.9, 9.2, 10.4, 10.6, 19.3]

      # alpha, by default, is 0.05
      result = described_class.two_samples(group_one: group_one, group_two: group_two)

      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
      expect(result[:d_max]).to eq 0.6
    end

    it 'computes a two-sided Kolmogorov-Smirnov test for two samples, following example TWO' do
      # Calculation in R
      # Two-sample Kolmogorov-Smirnov test
      #
      # D = 1, p-value = 6.657e-08
      # alternative hypothesis: two-sided

      men = RubyStatistics::Distribution::Normal.new(3.0, 1.0).random(elements: 10, seed: 100)
      women = RubyStatistics::Distribution::Weibull.new(2.0, 3.0).random(elements: 20, seed: 100)

      # alpha, by default, is 0.05
      result = described_class.two_samples(group_one: men, group_two: women)

      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
      expect(result[:d_max]).to eq 1.0
    end

    it 'computes a two-sided Kolmogorov-Smirnov test for two samples, following example THREE' do
      # Calculation in R
      # Two-sample Kolmogorov-Smirnov test
      #
      # D = 0.4, p-value = 0.873
      # alternative hypothesis: two-sided

      men = RubyStatistics::Distribution::StandardNormal.new.random(elements: 500, seed: 10)
      women = RubyStatistics::Distribution::StandardNormal.new.random(elements: 50, seed: 40)

      # alpha, by default, is 0.05
      result = described_class.two_samples(group_one: men, group_two: women)

      puts result
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
      expect(result[:d_max]).to eq 0.12
    end
  end
end
