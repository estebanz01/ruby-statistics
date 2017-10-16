require 'spec_helper'

describe Statistics::StatisticalTest::FTest do
  describe '.anova_f_score' do
    context 'when only two groups have been specified' do
      let(:group_one) { (1..15).to_a.sample(5) }
      let(:group_two) { (1..15).to_a.sample(5) }
      let(:variances) { [group_one.variance, group_two.variance] }
      let(:result) { described_class.anova_f_score(group_one, group_two) }

      it 'calculates the F statistic using the ratio of variances' do
        expect(result[0]).to eq variances.max / variances.min.to_f
      end

      it 'returns the degrees of freedom of the numerator as one' do
        expect(result[1]).to eq 1
      end

      it 'returns the degrees of freedom of the denominator as N-k' do
        df = group_one.size + group_two.size - 2

        expect(result[2]).to eq df
      end
    end

    # The following groups and values are a replica of the example
    # explained here: https://courses.lumenlearning.com/boundless-statistics/chapter/one-way-anova
    context 'when more than two groups have been specified' do
      let(:sorority_one) { [2.17, 1.85, 2.83, 1.69, 3.33] }
      let(:sorority_two) { [2.63, 1.77, 3.25, 1.86, 2.21] }
      let(:sorority_three) { [2.63, 3.78, 4.00, 2.55, 2.45] }
      let(:sorority_four) { [3.79, 3.45, 3.08, 2.26, 3.18] }

      let(:result) do
        described_class.anova_f_score(sorority_one,
                                      sorority_two,
                                      sorority_three,
                                      sorority_four)
      end

      it 'calculates the variances between and within groups to retrieve the F-statistic' do
        expect(result[0].round(2)).to eq 2.23
      end

      it 'calculates the correct degrees of freedom for the specified groups' do
        expect(result[1]).to eq 3
        expect(result[2]).to eq 16
      end
    end
  end

  describe '.one_way_anova' do
    it 'calculates the ANOVA F-score' do
      expect(described_class).to receive(:anova_f_score)

      described_class.one_way_anova(0.1, [1, 2, 3], [4, 5, 6])
    end

    # example ONE
    # explained here: https://courses.lumenlearning.com/boundless-statistics/chapter/one-way-anova
    # Four sororities took a random sample of sisters regarding their grade means for the past term.
    # Using a significance level of 1%, is there a difference in mean grades among the sororities?
    it 'performs a One way ANOVA Test following example ONE' do
      sorority_one = [2.17, 1.85, 2.83, 1.69, 3.33]
      sorority_two = [2.63, 1.77, 3.25, 1.86, 2.21]
      sorority_three = [2.63, 3.78, 4.00, 2.55, 2.45]
      sorority_four = [3.79, 3.45, 3.08, 2.26, 3.18]
      alpha = 0.1

      result = described_class.one_way_anova(alpha,
                                             sorority_one,
                                             sorority_two,
                                             sorority_three,
                                             sorority_four)

      expect(result[:p_value].round(4)).to eq 0.1241

      # Accept null hypotheses ?
      expect(result[:null]).to be true

      # Accept alternative hypotheses ?
      expect(result[:alternative]).to be false

      # Confidence level (90 %)
      expect(result[:confidence_level]).to eq 0.9
    end

    # example TWO
    # explained here: https://web.mst.edu/~psyworld/anovaexample.htm
    # Susan Sound predicts that students will learn most effectively with a constant background sound,
    # as opposed to an unpredictable sound or no sound at all. She randomly divides twenty-four students
    # into three groups of eight. All students study a passage of text for 30 minutes.
    # Those in group 1 study with background sound at a constant volume in the background.
    # Those in group 2 study with noise that changes volume periodically.
    # Those in group 3 study with no sound at all.
    # After studying, all students take a 10 point multiple choice test over the material.
    it 'perfoms a One way ANOVA Test following example TWO' do
      constant_sound = [7, 4, 6, 8, 6, 6, 2, 9]
      random_sound = [5, 5, 3, 4, 4, 7, 2, 2]
      no_sound = [2, 4, 7, 1, 2, 1, 5, 5]
      alpha = 0.05

      result = described_class.one_way_anova(alpha,
                                             constant_sound,
                                             random_sound,
                                             no_sound)

      expect(result[:p_value].round(3)).to eq 0.045
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end
  end
end
