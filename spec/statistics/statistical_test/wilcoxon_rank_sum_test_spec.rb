require 'spec_helper'

describe Statistics::StatisticalTest::WilcoxonRankSumTest do
  let(:test_class) { described_class.new }

  it 'can be instantiated using the MannWhitneyU alias' do
    expect(described_class).to eq Statistics::StatisticalTest::MannWhitneyU
  end

  describe '#rank' do
    it 'ranks an specified group of elements according to the Mann-whitney U test' do
      oceanic_earthquakes = [75, 32, 50, 38, 19, 44, 33, 102, 28, 70, 49, 70]
      continental_earthquakes = [69, 99, 135, 115, 33, 92, 118, 115, 92, 89, 101]
      earthquakes = oceanic_earthquakes + continental_earthquakes

      # When there is a tie, the final rank is calculated when computing the test.
      # This can be found it by dividing counter and rank.
      # e.g.: 33 => { counter: 2, rank: 9 } can be seen as 33 - 4.5; 33 - 4.5
      result = { 19=>{:counter=>1, :rank=>1}, 28=>{:counter=>1, :rank=>2},
                 32=>{:counter=>1, :rank=>3}, 33=>{:counter=>2, :rank=>9},
                 38=>{:counter=>1, :rank=>6}, 44=>{:counter=>1, :rank=>7},
                 49=>{:counter=>1, :rank=>8}, 50=>{:counter=>1, :rank=>9},
                 69=>{:counter=>1, :rank=>10}, 70=>{:counter=>2, :rank=>23},
                 75=>{:counter=>1, :rank=>13}, 89=>{:counter=>1, :rank=>14},
                 92=>{:counter=>2, :rank=>31}, 99=>{:counter=>1, :rank=>17},
                 101=>{:counter=>1, :rank=>18}, 102=>{:counter=>1, :rank=>19},
                 115=>{:counter=>2, :rank=>41}, 118=>{:counter=>1, :rank=>22},
                 135=>{:counter=>1, :rank=>23} }

      expect(test_class.rank(earthquakes)).to eq result
    end
  end

  ## Examples
  # Example ONE extracted from http://users.sussex.ac.uk/~grahamh/RM1web/Mann-Whitney%20worked%20example.pdf
  # The  effectiveness  of  advertising  for  two  rival  products  (Brand  X  and Brand  Y)  was  compared.
  #
  # Example TWO and THREE extracted from http://webspace.ship.edu/pgmarr/Geo441/Lectures/Lec%207%20-%20Mann-Whitney%20and%20Paired%20Tests.pdf
  # both examples tries to identify if there is significant difference between oceanic and continental
  # earthquakes compared by magnitude (TWO) and depth (THREE).
  describe '#perform' do
    it 'always computes the test approximating the U-statistic to the standard normal distribution' do
      expect_any_instance_of(Distribution::StandardNormal)
        .to receive(:cumulative_function).and_call_original

      result = test_class.perform(0.05, :two_tail, [1,2,3], [4,5,6])

      expect(result.keys).to include :z
    end

    it 'performs a wilcoxon rank sum/Mann-Whitney U test following example ONE' do
      rating_x = [3, 4, 2, 6, 2, 5]
      rating_y = [9, 7, 5, 10, 6, 8]

      result = test_class.perform(0.05, :two_tail, rating_x, rating_y)

      expect(result[:u]).to eq 2
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
      expect(result[:p_value].round(2)).to eq 0.01
    end

    it 'performs a wilcoxon rank sum/Mann-Whitney U test following example TWO' do
      oceanic_magnitudes = [3.9, 4.0, 4.1, 4.3, 4.3, 4.4, 4.5, 4.8, 5.4, 6.3, 6.8, 6.8]
      continental_magnitudes = [4.1, 4.3, 4.3, 4.3, 4.4, 4.4, 4.5, 4.6, 5.0, 5.1, 5.1]

      result = test_class.perform(0.05, :two_tail, oceanic_magnitudes, continental_magnitudes)

      expect(result[:u]).to eq 63 # In the example, they use the largest instead of the lowest.
      expect(result[:z].round(3)).to eq -0.186
      expect(result[:null]).to be true
      expect(result[:alternative]).to be false
      expect(result[:p_value]).to eq 0.8525013990549617
    end

    it 'performs a wilcoxon rank sum/Mann-Whitney U test following example THREE' do
      oceanic_earthquakes = [75, 32, 50, 38, 19, 44, 33, 102, 28, 70, 49, 70]
      continental_earthquakes = [69, 99, 135, 115, 33, 92, 118, 115, 92, 89, 101]

      result = test_class.perform(0.05, :two_tail, oceanic_earthquakes, continental_earthquakes)

      expect(result[:u]).to eq 17.5
      expect(result[:z].round(3)).to eq -2.988
      expect(result[:null]).to be false
      expect(result[:alternative]).to be true
      expect(result[:p_value]).to eq 0.002808806689028387
    end
  end
end
