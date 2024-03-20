require 'spec_helper'

describe RubyStatistics::SpearmanRankCoefficient do
  describe '.rank' do
    context 'when only ranks are needed' do
      it 'returns an array of elements corresponding to the expected ranks wihout altering order' do
        expected_ranks = [4, 1, 3, 2, 5]

        result = described_class.rank(data: [10, 30, 12, 15, 3], return_ranks_only: true)

        expect(result).to eq expected_ranks
      end
    end

    context 'when ranks and passed elements are needed' do
      it 'returns a hash composed by the elements and ranking information' do
        expected_ranks = {
          30 => { counter: 1, rank: 1, tie_rank: 1 },
          15 => { counter: 1, rank: 2, tie_rank: 2 },
          12 => { counter: 1, rank: 3, tie_rank: 3 },
          10 => { counter: 1, rank: 4, tie_rank: 4 },
          3 => { counter: 1, rank: 5, tie_rank: 5 }
        }

        result = described_class.rank(data: [10, 30, 12, 15, 3], return_ranks_only: false)

        expect(result).to eq expected_ranks
      end
    end

    context 'when there are ties' do
      it 'returns a ranking list with solved ties when ranks only are needed' do
        expected_ranking = [9, 3, 10, 4, 6.5, 5, 8, 1, 2, 6.5]
        data = [56, 75, 45, 71, 61, 64, 58, 80, 76, 61]

        result = described_class.rank(data: data, return_ranks_only: true)

        expect(result).to eq expected_ranking
      end

      it 'returns a hash composed by the elements and some ranking information' do
        expected_ranks = {
          80 => { counter: 1, rank: 1, tie_rank: 1 },
          76 => { counter: 1, rank: 2, tie_rank: 2 },
          75 => { counter: 1, rank: 3, tie_rank: 3 },
          71 => { counter: 1, rank: 4, tie_rank: 4 },
          64 => { counter: 1, rank: 5, tie_rank: 5 },
          61 => { counter: 2, rank: 13, tie_rank: 6.5 },
          58 => { counter: 1, rank: 8, tie_rank: 8 },
          56 => { counter: 1, rank: 9, tie_rank: 9 },
          45 => { counter: 1, rank: 10, tie_rank: 10 }
        }
        data = [56, 75, 45, 71, 61, 64, 58, 80, 76, 61]

        result = described_class.rank(data: data, return_ranks_only: false)

        expect(result).to include(expected_ranks)
      end

      it 'returns a hash containing information about the existing ties' do
        tie_rank = { 61 => { counter: 2, tie_rank: 6.5, rank: 13 } }
        data = [56, 75, 45, 71, 61, 64, 58, 80, 76, 61]

        result = described_class.rank(data: data, return_ranks_only: false)

        expect(result).to include(tie_rank)
      end
    end
  end

  describe '.coefficient' do
    it 'raises an error when the groups have different number of cases' do
      expect do
        described_class.coefficient([1, 2, 3], [1, 2, 3, 4])
      end.to raise_error(StandardError, 'Both group sets must have the same number of cases.')
    end

    it 'returns nothing when both groups have a size of zero cases' do
      expect(described_class.coefficient([], [])).to be_nil
    end

    context 'when there are ties in the data' do
      it 'calculates the spearman rank coefficient for example one' do
        # Example taken from http://www.biostathandbook.com/spearman.html
        volume = [1760, 2040, 2440, 2550, 2730, 2740, 3010, 3080, 3370, 3740, 4910, 5090, 5090, 5380, 5850, 6730, 6990, 7960]
        frequency = [529, 566, 473, 461, 465, 532, 484, 527, 488, 485, 478, 434, 468, 449, 425, 389, 421, 416]

        volume_rank = described_class.rank(data: volume)
        frequency_rank = described_class.rank(data: frequency)

        rho = described_class.coefficient(volume_rank, frequency_rank)
        expect(rho.round(7)).to eq -0.7630357
      end

      it 'calcultes the spearman rank coefficient for example two' do
        # Example taken from https://geographyfieldwork.com/SpearmansRank.htm
        # Results from R:
        # cor(c(50, 175, 270, 375, 425, 580, 710, 790, 890, 980), c(1.80, 1.20, 2.0, 1.0, 1.0, 1.20, 0.80, 0.60, 1.0, 0.85), method = 'spearman')
        # [1] -0.7570127
        distance = [50, 175, 270, 375, 425, 580, 710, 790, 890, 980]
        price = [1.80, 1.20, 2.0, 1.0, 1.0, 1.20, 0.80, 0.60, 1.0, 0.85]

        distance_rank = described_class.rank(data: distance)
        price_rank = described_class.rank(data: price)

        rho = described_class.coefficient(distance_rank, price_rank)

        expect(rho.round(7)).to eq -0.7570127
      end

      it 'calculates the spearman rank coefficient for example three' do
        # Example taken from http://www.real-statistics.com/correlation/spearmans-rank-correlation/spearmans-rank-correlation-detailed/

        life_exp = [80, 78, 60, 53, 85, 84, 73, 79, 81, 75, 68, 72, 58, 92, 65]
        cigarretes = [5, 23, 25, 48, 17, 8, 4, 26, 11, 19, 14, 35, 29, 4, 23]

        life_rank = described_class.rank(data: life_exp)
        cigarretes_rank = described_class.rank(data: cigarretes)

        rho = described_class.coefficient(life_rank, cigarretes_rank)

        expect(rho.round(7)).to eq -0.6744197
      end
    end

    context 'when there are no ties in the data' do
      it 'calculates the spearman rank coefficient for example one' do
        # Example taken from here: https://statistics.laerd.com/statistical-guides/spearmans-rank-order-correlation-statistical-guide-2.php
        english_data = [56, 75, 45, 71, 62, 64, 58, 80, 76, 61]
        math_data = [66, 70, 40, 60, 65, 56, 59, 77, 67, 63]

        english_rank = described_class.rank(data: english_data)
        math_rank = described_class.rank(data: math_data)

        rho = described_class.coefficient(english_rank, math_rank)

        expect(rho.round(2)).to eq 0.67
      end

      it 'calculates the spearman rank coefficient for example two' do
        # Example taken from here: https://www.statisticshowto.datasciencecentral.com/spearman-rank-correlation-definition-calculate/
        physics = [35, 23, 47, 17, 10, 43, 9, 6, 28]
        math = [30, 33, 45, 23, 8, 49, 12, 4, 31]

        physics_rank = described_class.rank(data: physics)
        math_rank = described_class.rank(data: math)

        rho = described_class.coefficient(physics_rank, math_rank)

        expect(rho).to eq 0.9
      end
    end
  end
end
