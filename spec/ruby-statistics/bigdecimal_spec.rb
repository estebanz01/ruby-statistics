require 'spec_helper'
require 'bigdecimal'
require 'bigdecimal/util'

describe BigDecimal do
  context 'when bigdecimal is passed to personalized math functions' do
    it 'truncates the decimal numbers and calculates the factorial for the real part' do
      expect(Math.factorial(BigDecimal(5.45354598234834, 16))).to eq 120
    end

    it 'calculates the possible permutations of k objects from a set of n elements' do
      expect(Math.permutation(BigDecimal(15, 1), BigDecimal(4, 1))).to eq 32760
      expect(Math.permutation(BigDecimal(16, 1), BigDecimal(3, 1))).to eq 3360 # 16 balls, choose 3.
      expect(Math.permutation(BigDecimal(10, 1), BigDecimal(2, 1))).to eq 90 # 10 people to select 1th and 2nd place.
    end

    it 'calculates the possible combinations of k object from a set of n elements' do
      expect(Math.combination(BigDecimal(16, 1), BigDecimal(3, 1))).to eq 560 # Order 16 balls in 3 ways.
      expect(Math.combination(BigDecimal(5, 1), BigDecimal(3, 1))).to eq 10 # How to choose 3 people out of 5.
      expect(Math.combination(BigDecimal(12, 1), BigDecimal(5, 1))).to eq 792 # How to choose 5 games out of 12.
    end

    it 'approximates a solution in the [a,b] interval for the integral of the specified function' do
      lower = BigDecimal(rand(10), 1)
      upper = BigDecimal(rand(11..20), 1)

      function_a = Math.simpson_rule(lower, upper, 10_000) do |x|
        x ** 2
      end

      function_b = Math.simpson_rule(lower, upper, 10_000) do |x|
        Math.sin(x)
      end

      res_a = ((upper ** 3)/3.0) - ((lower ** 3)/3.0) # Integral of x^2
      res_b = -Math.cos(upper) + Math.cos(lower) # Integral of sin(x)

      expect(function_a.floor).to eq res_a.floor
      expect(function_b.floor).to eq res_b.floor
    end

    it 'returns the expected calculationi for the lower incomplete gamma function' do
      results = [0.6322, 0.594, 1.1536, 3.3992, 13.4283]

      (1..5).each_with_index do |number, index|
        expect(
          Math.lower_incomplete_gamma_function(
            BigDecimal(number, 1), BigDecimal(number, 1)
          )
        ).to be_within(0.0001).of(results[index])
      end
    end

    it 'returns 1 for the special case x = y = 1 when calculating the beta function' do
      expect(Math.beta_function(BigDecimal(1, 1), BigDecimal(1, 1))).to eq 1
    end

    it 'Calculates the expected values for the beta function' do
      # TODO: Find a way to better test this instead of fixing some values.
      result = [1, 0.1667, 0.0333, 0.0071, 0.0016]

      (1..5).each_with_index do |number, index|
        expectation = Math.beta_function(
          BigDecimal(number, 1), BigDecimal(number, 1)
        )
        expect(expectation).to be_within(0.0001).of(result[index])
      end
    end

    it 'calculates the expected values for the incomplete beta function' do
      # The last 2 values:
      # For 9 is 0.9999979537560903519733 which is rounding to 1.0
      # For 10 is 1.0
      results = [
        0.19, 0.1808, 0.2557, 0.4059,
        0.6230, 0.8418, 0.9685, BigDecimal(0.9985, 5),
        BigDecimal(0.9999979537560903, 5), 1.0
      ]

      (1..10).each_with_index do |number, index|
        expect(
          Math.incomplete_beta_function(
            (number/10.0).to_d(16), BigDecimal(number, 1), BigDecimal(number + 1, 1)
          )
        ).to be_within(0.0001).of(results[index])
      end
    end
  end

  context 'when bigdecimal is used with chi squared distributions' do
    context 'With degrees of freedom from 1 to 30' do
      it 'returns the expected probabilities for the chi-squared distribution compared to a table' do
        alpha = 0.100

        values = RubyStatistics::Distribution::Tables::ChiSquared.alpha_column(alpha).map { |x|
            {
              df: x[:df],
              bd: BigDecimal(x[:critical_value], 5)
            }
        }[0, 30]

        values.each do |p|
          result = 1.0 - RubyStatistics::Distribution::ChiSquared.new(p[:df]).cumulative_function(p[:bd])
          expect(result).to be_within(0.0001).of(alpha)
        end
      end
    end

    context 'With degrees of freedom from 40 to 100, with a 10 unit increment' do
      it 'returns the expected probabilities for the chi-squared distribution compared to a table' do
        alpha = 0.100

        values = RubyStatistics::Distribution::Tables::ChiSquared.alpha_column(alpha).map { |x|
          {
            df: x[:df],
            bd: BigDecimal(x[:critical_value], 5)
          }
        }[30, 7]

        values.each do |p|
          result = 1.0 - RubyStatistics::Distribution::ChiSquared.new(p[:df]).cumulative_function(p[:bd])
          expect(result).to be_within(0.0001).of(alpha)
        end
      end
    end
  end

  context 'when bigdecimal is used in chi squared tests' do
    it 'perform a goodness of fit test following example ONE' do
      pending 'It is giving a less accurate p-value when using BigDecimal. It passes on Float numbers.'
      observed_counts = [
        BigDecimal(212, 1), BigDecimal(147, 1), BigDecimal(103, 1),
        BigDecimal(50, 1), BigDecimal(46, 1), BigDecimal(42, 1)
      ]
      expected = BigDecimal(100, 1)
      result = StatisticalTest::ChiSquaredTest.goodness_of_fit(0.05, expected, observed_counts)

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
      observed = [
        BigDecimal(224, 1), BigDecimal(119, 1), BigDecimal(130, 1),
        BigDecimal(48, 1), BigDecimal(59, 1)
      ]
      expected = [
        BigDecimal(232, 1), BigDecimal(116, 1), BigDecimal(116, 1),
        BigDecimal(58, 1), BigDecimal(58, 1)
      ]

      result = StatisticalTest::ChiSquaredTest.goodness_of_fit(0.05, expected, observed)

      expect(result[:p_value]).to be_within(0.0001).of(0.4359)
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
    end

    # The following test is based on the numbers reported in https://github.com/estebanz01/ruby-statistics/issues/78
    # which give us a minimum test case scenario where the integral being solved with simpson's rule
    # uses zero iterations, raising errors.
    it 'performs a goodness of fit test with values that generates small chi statistics' do
      observed_counts = [
        BigDecimal(481, 1), BigDecimal(483, 1),
        BigDecimal(482, 1), BigDecimal(488, 1),
        BigDecimal(478, 1), BigDecimal(471, 1),
        BigDecimal(477, 1), BigDecimal(479, 1),
        BigDecimal(475, 1), BigDecimal(462, 1)
      ]

      expected = BigDecimal(477, 1)

      result = {}

      expect do
        result = StatisticalTest::ChiSquaredTest.goodness_of_fit(0.01, expected, observed_counts)
      end.not_to raise_error

      expect(result[:p_value]).to be_within(0.0001).of(0.9995)
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
    end
  end

  context 'when bigdecimal is used in F tests' do
    # example ONE
    # explained here: https://courses.lumenlearning.com/boundless-statistics/chapter/one-way-anova
    # Four sororities took a random sample of sisters regarding their grade means for the past term.
    # Using a significance level of 1%, is there a difference in mean grades among the sororities?
    it 'performs a One way ANOVA Test following example ONE' do
      sorority_one = [
        BigDecimal(2.17, 3), BigDecimal(1.85, 3), BigDecimal(2.83, 3),
        BigDecimal(1.69, 3), BigDecimal(3.33, 3)
      ]
      sorority_two = [
        BigDecimal(2.63, 3), BigDecimal(1.77, 3), BigDecimal(3.25, 3),
        BigDecimal(1.86, 3), BigDecimal(2.21, 3)
      ]
      sorority_three = [
        BigDecimal(2.63, 3), BigDecimal(3.78, 3), BigDecimal(4.00, 3),
        BigDecimal(2.55, 3), BigDecimal(2.45, 3)
      ]
      sorority_four = [
        BigDecimal(3.79, 3), BigDecimal(3.45, 3), BigDecimal(3.08, 3),
        BigDecimal(2.26, 3), BigDecimal(3.18, 3)
      ]
      alpha = 0.1

      result = StatisticalTest::FTest.one_way_anova(alpha,
                                             sorority_one,
                                             sorority_two,
                                             sorority_three,
                                             sorority_four)

      expect(result[:p_value]).to be_within(0.0001).of(0.1241)

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
      constant_sound = [
        BigDecimal(7, 1), BigDecimal(4, 1), BigDecimal(6, 1), BigDecimal(8, 1),
        BigDecimal(6, 1), BigDecimal(6, 1), BigDecimal(2, 1), BigDecimal(9, 1)
      ]
      random_sound = [
        BigDecimal(5, 1), BigDecimal(5, 1), BigDecimal(3, 1), BigDecimal(4, 1),
        BigDecimal(4, 1), BigDecimal(7, 1), BigDecimal(2, 1), BigDecimal(2, 1)
      ]
      no_sound = [
        BigDecimal(2, 1), BigDecimal(4, 1), BigDecimal(7, 1), BigDecimal(1, 1),
        BigDecimal(2, 1), BigDecimal(1, 1), BigDecimal(5, 1), BigDecimal(5, 1)
      ]
      alpha = 0.05

      result = StatisticalTest::FTest.one_way_anova(alpha,
                                             constant_sound,
                                             random_sound,
                                             no_sound)

      expect(result[:p_value]).to be_within(0.001).of(0.045)
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end
  end

  context 'when bigdecimal is used in kolmogorov smirnov tests' do
    it 'computes a two-sided Kolmogorov-Smirnov test for two samples, following example ONE' do
      # Data extracted from http://www.stats.ox.ac.uk/~massa/Lecture%2013.pdf
      # calculation in R:
      # > ks.test(c(1.2,1.4,1.9,3.7,4.4,4.8,9.7,17.3,21.1,28.4), c(5.6,6.5,6.6,6.9,9.2,10.4,10.6,19.3))
      #
      #   Two-sample Kolmogorov-Smirnov test
      #
      #   D = 0.6, p-value = 0.04987
      #   alternative hypothesis: two-sided

      group_one = [
        BigDecimal(1.2, 3), BigDecimal(1.4, 3), BigDecimal(1.9, 3), BigDecimal(3.7, 3),
        BigDecimal(4.4, 3), BigDecimal(4.8, 3), BigDecimal(9.7, 3), BigDecimal(17.3, 3),
        BigDecimal(21.1, 3), BigDecimal(28.4, 3)
      ]
      group_two = [
        BigDecimal(5.6, 3), BigDecimal(6.5, 3), BigDecimal(6.6, 3), BigDecimal(6.9, 3),
        BigDecimal(9.2, 3), BigDecimal(10.4, 3), BigDecimal(10.6, 3), BigDecimal(19.3, 3)
      ]

      # alpha, by default, is 0.05
      result = StatisticalTest::KSTest.two_samples(group_one: group_one, group_two: group_two)

      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
      expect(result[:d_max]).to eq 0.6
    end
  end

  context 'when bigdecimal is used in wilcoxon rank sum test' do
    ## Examples
    # Example ONE extracted from http://users.sussex.ac.uk/~grahamh/RM1web/Mann-Whitney%20worked%20example.pdf
    # The  effectiveness  of  advertising  for  two  rival  products  (Brand  X  and Brand  Y)  was  compared.
    #
    # Example TWO and THREE extracted from http://webspace.ship.edu/pgmarr/Geo441/Lectures/Lec%207%20-%20Mann-Whitney%20and%20Paired%20Tests.pdf
    # both examples tries to identify if there is significant difference between oceanic and continental
    # earthquakes compared by magnitude (TWO) and depth (THREE).
    it 'performs a wilcoxon rank sum/Mann-Whitney U test following example ONE' do
      rating_x = [
        BigDecimal(3, 1), BigDecimal(4, 1), BigDecimal(2, 1), BigDecimal(6, 1),
        BigDecimal(2, 1), BigDecimal(5, 1)
      ]
      rating_y = [
        BigDecimal(9, 1), BigDecimal(7, 1), BigDecimal(5, 1), BigDecimal(10, 1),
        BigDecimal(6, 1), BigDecimal(8, 1)
      ]

      result = StatisticalTest::WilcoxonRankSumTest.new.perform(0.05, :two_tail, rating_x, rating_y)

      expect(result[:u]).to eq 2
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
      expect(result[:p_value]).to be_within(0.01).of(0.01)
    end

    it 'performs a wilcoxon rank sum/Mann-Whitney U test following example TWO' do
      oceanic_magnitudes = [
        BigDecimal(3.9, 3), BigDecimal(4.0, 3), BigDecimal(4.1, 3), BigDecimal(4.3, 3),
        BigDecimal(4.3, 3), BigDecimal(4.4, 3), BigDecimal(4.5, 3), BigDecimal(4.8, 3),
        BigDecimal(5.4, 3), BigDecimal(6.3, 3), BigDecimal(6.8, 3), BigDecimal(6.8, 3)
      ]
      continental_magnitudes = [
        BigDecimal(4.1, 3), BigDecimal(4.3, 3), BigDecimal(4.3, 3), BigDecimal(4.3, 3),
        BigDecimal(4.4, 3), BigDecimal(4.4, 3), BigDecimal(4.5, 3), BigDecimal(4.6, 3),
        BigDecimal(5.0, 3), BigDecimal(5.1, 3), BigDecimal(5.1, 3)
      ]

      result = StatisticalTest::WilcoxonRankSumTest.new.perform(0.05, :two_tail, oceanic_magnitudes, continental_magnitudes)

      expect(result[:u]).to eq 63 # In the example, they use the largest instead of the lowest.
      expect(result[:z]).to be_within(0.01).of(-0.186)
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
      expect(result[:p_value]).to eq 0.8525013990549617
    end

    it 'performs a wilcoxon rank sum/Mann-Whitney U test following example THREE' do
      oceanic_earthquakes = [
        BigDecimal(75, 1), BigDecimal(32, 1), BigDecimal(50, 1), BigDecimal(38, 1),
        BigDecimal(19, 1), BigDecimal(44, 1), BigDecimal(33, 1), BigDecimal(102, 1),
        BigDecimal(28, 1), BigDecimal(70, 1), BigDecimal(49, 1), BigDecimal(70, 1)
      ]
      continental_earthquakes = [
        BigDecimal(69, 1), BigDecimal(99, 1), BigDecimal(135, 1), BigDecimal(115, 1),
        BigDecimal(33, 1), BigDecimal(92, 1), BigDecimal(118, 1), BigDecimal(115, 1),
        BigDecimal(92, 1), BigDecimal(89, 1), BigDecimal(101, 1)
      ]

      result = StatisticalTest::WilcoxonRankSumTest.new.perform(0.05, :two_tail, oceanic_earthquakes, continental_earthquakes)

      expect(result[:u]).to eq 17.5
      expect(result[:z]).to be_within(0.001).of(-2.988)
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
      expect(result[:p_value]).to eq 0.002808806689028387
    end
  end

  context 'when bigdecimal is used in t-tests' do
    # Example with one sample
    # explained here: https://secure.brightstat.com/index.php?id=40
    # A random sample of 22 fifth grade pupils have a grade point average of 5.0 in maths
    # with a standard deviation of 0.452, whereas marks range from 1 (worst) to 6 (excellent).
    # The grade point average (GPA) of all fifth grade pupils of the last five years is 4.7.
    # Is the GPA of the 22 pupils different from the populations’ GPA?
    it 'performs a t-test with one sample for one tail' do
      student_grades = [
        BigDecimal(5, 3), BigDecimal(5.5, 3), BigDecimal(4.5, 3), BigDecimal(5, 3),
        BigDecimal(5, 3), BigDecimal(6, 3), BigDecimal(5, 3), BigDecimal(5, 3),
        BigDecimal(4.5, 3), BigDecimal(5, 3), BigDecimal(5, 3), BigDecimal(4.5, 3),
        BigDecimal(4.5, 3), BigDecimal(5.5, 3), BigDecimal(4, 3), BigDecimal(5, 3),
        BigDecimal(5, 3), BigDecimal(5.5, 3), BigDecimal(4.5, 3), BigDecimal(5.5, 3),
        BigDecimal(5, 3), BigDecimal(5.5, 3)
      ]
      alpha = 0.05

      result = StatisticalTest::TTest.perform(alpha, :one_tail, 4.7, student_grades)

      expect(result[:p_value]).to be_within(0.000001).of(0.003114) # R 3.5.1. calculates the p_value as 0.003114
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
    end

    it 'performs a t-test with one sample for two tails' do
      student_grades = [
        BigDecimal(5, 3), BigDecimal(5.5, 3), BigDecimal(4.5, 3), BigDecimal(5, 3),
        BigDecimal(5, 3), BigDecimal(6, 3), BigDecimal(5, 3), BigDecimal(5, 3),
        BigDecimal(4.5, 3), BigDecimal(5, 3), BigDecimal(5, 3), BigDecimal(4.5, 3),
        BigDecimal(4.5, 3), BigDecimal(5.5, 3), BigDecimal(4, 3), BigDecimal(5, 3),
        BigDecimal(5, 3), BigDecimal(5.5, 3), BigDecimal(4.5, 3), BigDecimal(5.5, 3),
        BigDecimal(5, 3), BigDecimal(5.5, 3)
      ]
      alpha = 0.05

      result = StatisticalTest::TTest.perform(alpha, :two_tail, 4.7, student_grades)

      expect(result[:p_value]).to be_within(0.000001).of(0.006229) # R 3.5.1. calculates the p_value as 0.006229
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
        older_adults = [
          BigDecimal(45, 1), BigDecimal(38, 1), BigDecimal(52, 1), BigDecimal(48, 1),
          BigDecimal(25, 1), BigDecimal(39, 1), BigDecimal(51, 1), BigDecimal(46, 1),
          BigDecimal(55, 1), BigDecimal(46, 1)
        ]
        younger_adults = [
          BigDecimal(34, 1), BigDecimal(22, 1), BigDecimal(15, 1), BigDecimal(27, 1),
          BigDecimal(37, 1), BigDecimal(41, 1), BigDecimal(24, 1), BigDecimal(19, 1),
          BigDecimal(26, 1), BigDecimal(36, 1)
        ]
        alpha = 0.05

        result = StatisticalTest::TTest.perform(alpha, :two_tail, older_adults, younger_adults)

        expect(result[:t_score]).to be_within(0.0001).of(4.2575)
        expect(result[:null]).to be false
        expect(result[:alternative]).to be true

        result = StatisticalTest::TTest.perform(alpha, :two_tail, younger_adults, older_adults)

        expect(result[:t_score]).to be_within(0.0001).of(4.2575)
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
        experimental = [
          BigDecimal(35, 1), BigDecimal(40, 1), BigDecimal(12, 1), BigDecimal(15, 1),
          BigDecimal(21, 1), BigDecimal(14, 1), BigDecimal(46, 1), BigDecimal(10, 1),
          BigDecimal(28, 1), BigDecimal(48, 1), BigDecimal(16, 1), BigDecimal(30, 1),
          BigDecimal(32, 1), BigDecimal(48, 1), BigDecimal(31, 1), BigDecimal(22, 1),
          BigDecimal(12, 1), BigDecimal(39, 1), BigDecimal(19, 1), BigDecimal(25, 1)
        ]
        comparison = [
          BigDecimal(2, 1), BigDecimal(27, 1), BigDecimal(38, 1), BigDecimal(31, 1),
          BigDecimal(1, 1), BigDecimal(19, 1), BigDecimal(1, 1), BigDecimal(34, 1),
          BigDecimal(3, 1), BigDecimal(1, 1), BigDecimal(2, 1), BigDecimal(3, 1),
          BigDecimal(2, 1), BigDecimal(1, 1), BigDecimal(2, 1), BigDecimal(1, 1),
          BigDecimal(3, 1), BigDecimal(29, 1), BigDecimal(37, 1), BigDecimal(2, 1)
        ]
        alpha = 0.01

        result = StatisticalTest::TTest.perform(alpha, :one_tail, experimental, comparison)

        expect(result[:t_score]).to be_within(0.0001).of(3.5341)
        expect(result[:null]).to be false
        expect(result[:alternative]).to be true

        result = StatisticalTest::TTest.perform(alpha, :one_tail, comparison, experimental)

        expect(result[:t_score]).to be_within(0.0001).of(3.5341)
        expect(result[:null]).to be false
        expect(result[:alternative]).to be true
      end
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
        older_adults = [
          BigDecimal(45, 1), BigDecimal(38, 1), BigDecimal(52, 1), BigDecimal(48, 1),
          BigDecimal(25, 1), BigDecimal(39, 1), BigDecimal(51, 1), BigDecimal(46, 1),
          BigDecimal(55, 1), BigDecimal(46, 1)
        ]
        younger_adults = [
          BigDecimal(34, 1), BigDecimal(22, 1), BigDecimal(15, 1), BigDecimal(27, 1),
          BigDecimal(37, 1), BigDecimal(41, 1), BigDecimal(24, 1), BigDecimal(19, 1),
          BigDecimal(26, 1), BigDecimal(36, 1)
        ]
        alpha = 0.05

        result = StatisticalTest::TTest.perform(alpha, :two_tail, older_adults, younger_adults)

        expect(result[:t_score]).to be_within(0.0001).of(4.2575)
        expect(result[:null]).to be false
        expect(result[:alternative]).to be true

        result = StatisticalTest::TTest.perform(alpha, :two_tail, younger_adults, older_adults)

        expect(result[:t_score]).to be_within(0.0001).of(4.2575)
        expect(result[:null]).to be false
        expect(result[:alternative]).to be true
      end
    end

    describe '.paired_test' do
      # example ONE
      # explained here: https://onlinecourses.science.psu.edu/stat500/node/51
      # Trace metals in drinking water affect the flavor and an unusually high concentration can pose a health hazard.
      # Ten pairs of data were taken measuring zinc concentration in bottom water and surface.
      # Does the data suggest that the true average concentration in the bottom water exceeds that of surface water?
      it 'performs a paired t-test following example ONE' do
        group_one = [
          BigDecimal(0.430, 4), BigDecimal(0.266, 4), BigDecimal(0.567, 4), BigDecimal(0.531, 4),
          BigDecimal(0.707, 4), BigDecimal(0.716, 4), BigDecimal(0.651, 4), BigDecimal(0.589, 4),
          BigDecimal(0.469, 4), BigDecimal(0.723, 4)
        ]
        group_two = [
          BigDecimal(0.415, 4), BigDecimal(0.238, 4), BigDecimal(0.390, 4), BigDecimal(0.410, 4),
          BigDecimal(0.605, 4), BigDecimal(0.609, 4), BigDecimal(0.632, 4), BigDecimal(0.523, 4),
          BigDecimal(0.411, 4), BigDecimal(0.612, 4)
        ]
        alpha = 0.05

        result = StatisticalTest::TTest.paired_test(alpha, :one_tail, group_one, group_two)

        expect(result[:t_score]).to be_within(0.0001).of(4.8638)
        expect(result[:null]).to be false
        expect(result[:alternative]).to be true
      end
    end
  end
end
