require 'spec_helper'

describe Statistics::StatisticalTest::TTest do
  describe '.perform' do
    context 'when there is an standard deviation of zero' do
      let(:alpha) { 0.05 }

      it 'does not perform a t-test when standard deviation of zero' do
        sample_1 = [1.0, 1.0, 1.0]

        error_msg = 'Standard deviation for the difference is zero. Please, reconsider sample contents'

        expect do
          described_class.perform(alpha, :one_tail, sample_1)
        end.to raise_error(described_class::ZeroStdError,  error_msg)
      end
    end

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

  describe '.paired_test' do
    context 'when both samples have an standard deviation of zero' do
      let(:alpha) { 0.05 }

      it 'does not perform a paired test when both samples are the same' do
        sample_1 = [1.0, 2.0]
        sample_2 = sample_1

        expect do
          described_class.paired_test(alpha, :one_tail, sample_1, sample_2)
        end.to raise_error(StandardError, 'both samples are the same')
      end

      it 'does not perform a paired test when both samples have an standard deviation of zero' do
        sample_1 = [1.0, 2.0, 3.0]
        sample_2 = [2.0, 3.0, 4.0]

        error_msg = 'Standard deviation for the difference is zero. Please, reconsider sample contents'

        expect do
          described_class.paired_test(alpha, :one_tail, sample_1, sample_2)
        end.to raise_error(described_class::ZeroStdError,  error_msg)
      end
    end

    # example ONE
    # explained here: https://onlinecourses.science.psu.edu/stat500/node/51
    # Trace metals in drinking water affect the flavor and an unusually high concentration can pose a health hazard.
    # Ten pairs of data were taken measuring zinc concentration in bottom water and surface.
    # Does the data suggest that the true average concentration in the bottom water exceeds that of surface water?
    it 'performs a paired t-test following example ONE' do
      group_one = [0.430, 0.266, 0.567, 0.531, 0.707, 0.716, 0.651, 0.589, 0.469, 0.723]
      group_two = [0.415, 0.238, 0.390, 0.410, 0.605, 0.609, 0.632, 0.523, 0.411, 0.612]
      alpha = 0.05

      result = described_class.paired_test(alpha, :one_tail, group_one, group_two)

      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end

    # example TWO
    # explained here: https://www.statsdirect.com/help/parametric_methods/paired_t.htm
    # Comparison of peak expiratory flow rate (PEFR) before and after a walk on a cold winter's day for a random sample of 9 asthmatics.
    it 'performs a paired t-test following example TWO - one tail' do
      before = [312, 242, 340, 388, 296, 254, 391, 402, 290]
      after = [300, 201, 232, 312, 220, 256, 328, 330, 231]
      alpha = 0.05

      result = described_class.paired_test(alpha, :one_tail, before, after)

      expect(result[:p_value].round(4)).to eq 0.0006
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end

    it 'performs a paired t-test following example TWO - two tail' do
      before = [312, 242, 340, 388, 296, 254, 391, 402, 290]
      after = [300, 201, 232, 312, 220, 256, 328, 330, 231]
      alpha = 0.05

      result = described_class.paired_test(alpha, :two_tail, before, after)

      expect(result[:p_value].round(4)).to eq 0.0012
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end

    # Example THREE
    # explained here: http://www.unm.edu/~marcusj/Paired2Sample.pdf
    # we would hypothesize that the width of survey transects between individuals effects the
    # density estimate of artifacts per unit area, however, we wish to test this hypothesis formally.
    it 'performs a paired t-test following example THREE' do
      five_mts = [9.998, 140.228, 40.669, 40.030, 86.292, 76.255, 16.689, 115.963, 161.497, 29.529,
                  37.765, 16.919, 22.415, 4.496, 22.272, 73.061, 57.477, 64.188, 40.958, 10.224,
                  91.245, 38.836, 160.985, 1.452, 209.540]
      ten_mts = [15.384, 54.803, 38.913, 10.875, 10.733, 36.444, 34.774, 49.252, 51.759, 0.643,
                 0.908, 114.969, 42.673, 43.370, 27.073, 19.343, 27.489, 2.808, 2.994, 95.575,
                 53.564, 32.265, 42.102, 3.544, 11.333]
      alpha = 0.05

      result = described_class.paired_test(alpha, :two_tail, five_mts, ten_mts)

      expect(result[:p_value].round(3)).to eq 0.026
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end
  end
end
