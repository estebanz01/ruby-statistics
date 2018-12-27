require 'spec_helper'

describe Statistics::SpearmanRankCoefficient do
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
        expect(rho.round(3)).to eq -0.763
      end
    end

    context 'when there are no ties in the data' do
      it 'calculates the spearman rank coefficient' do
        # Example taken from here: https://statistics.laerd.com/statistical-guides/spearmans-rank-order-correlation-statistical-guide-2.php
        english_data = [56, 75, 45, 71, 62, 64, 58, 80, 76, 61]
        math_data = [66, 70, 40, 60, 65, 56, 59, 77, 67, 63]

        english_rank = described_class.rank(data: english_data)
        math_rank = described_class.rank(data: math_data)

        rho = described_class.coefficient(english_rank, math_rank)

        expect(rho.round(2)).to eq 0.67
      end
    end
  end
end
