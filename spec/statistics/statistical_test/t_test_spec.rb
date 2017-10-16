require 'spec_helper'

describe Statistics::StatisticalTest::TTest do
  describe '.perform' do
    # Example with one sample
    # explained here: https://secure.brightstat.com/index.php?id=40
    # A random sample of 22 fifth grade pupils have a grade point average of 5.0 in maths
    # with a standard deviation of 0.452, whereas marks range from 1 (worst) to 6 (excellent).
    # The grade point average (GPA) of all fifth grade pupils of the last five years is 4.7.
    # Is the GPA of the 22 pupils different from the populations’ GPA?
    it 'performs a t-test with one sample' do
      student_grades = [5, 5.5, 4.5, 5, 5, 6, 5, 5, 4.5, 5, 5, 4.5, 4.5, 5.5, 4, 5, 5, 5.5, 4.5, 5.5, 5, 5.5]
      alpha = 0.05

      result = described_class.perform(alpha, :one_tail, 4.7, student_grades)

      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end

    context 'when two samples are specified' do
      # example ONE
      # explained here: http://faculty.webster.edu/woolflm/6aanswer.html
      #  A research study was conducted to examine the differences between older and younger adults
      #  on perceived life satisfaction. A pilot study was conducted to examine this hypothesis.
      #  Ten older adults (over the age of 70) and ten younger adults (between 20 and 30) were give
      #  a life satisfaction test (known to have high reliability and validity).
      #  Scores on the measure range from 0 to 60 with high scores indicative of high life satisfaction;
      #  low scores indicative of low life satisfaction. The data are presented below.

      it 'performs a t-test following example ONE' do
        older_adults = [45, 38, 52, 48, 25, 39, 51, 46, 55, 46]
        younger_adults = [34, 22, 15, 27, 37, 41, 24, 19, 26, 36]
        alpha = 0.05

        result = described_class.perform(alpha, :two_tail, older_adults, younger_adults)

        expect(result[:null]).to be false
        expect(result[:alternative]).to be true
      end

      # example TWO
      # explained here: http://www.indiana.edu/%7Eeducy520/sec6342/week_10/ttest_exp.pdf
      # Rosenthal and Jacobson (1968) informed classroom teachers that some of their students showed
      # unusual potential for intellectual gains. Eight months later the students identified to teachers as
      # having potentional for unusual intellectual gains showed significiantly greater gains performance
      # on a test said to measure IQ than did children who were not so identified.
      it 'performs a t-test following example TWO' do
        experimental = [35, 40, 12, 15, 21, 14, 46, 10, 28, 48, 16, 30, 32, 48, 31, 22, 12, 39, 19, 25]
        comparison = [2, 27, 38, 31, 1, 19, 1, 34, 3, 1, 2, 3, 2, 1, 2, 1, 3, 29, 37, 2]
        alpha = 0.01

        result = described_class.perform(alpha, :one_tail, experimental, comparison)

        expect(result[:null]).to be false
        expect(result[:alternative]).to be true
      end
    end
  end
end
