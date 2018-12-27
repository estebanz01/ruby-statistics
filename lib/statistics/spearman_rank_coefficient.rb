module Statistics
  class SpearmanRankCoefficient
    def self.rank(data:, return_ranks_only: true)
      descending_order_data = data.sort { |a, b| b <=> a }
      rankings = {}

      data.each do |value|
        temporal_ranking = descending_order_data.find_index(value) + 1 # 0-index

        if rankings.fetch(value, false)
          rankings[value][:rank] += (temporal_ranking + rankings[value][:counter])
          rankings[value][:counter] += 1
          rankings[value][:tie_rank] = rankings[value][:rank] / rankings[value][:counter].to_f
        else
          rankings[value] = { counter: 1, rank: temporal_ranking, tie_rank: temporal_ranking }
        end
      end

      if return_ranks_only
        data.map do |value|
          rankings[value][:tie_rank]
        end
      else
        rankings
      end
    end

    # Formulas extracted from: https://statistics.laerd.com/statistical-guides/spearmans-rank-order-correlation-statistical-guide.php
    def self.coefficient(set_one, set_two)
      raise 'Both group sets must have the same number of cases.' if set_one.size != set_two.size
      return if set_one.size == 0 && set_two.size == 0

      set_one_mean, set_two_mean = set_one.mean, set_two.mean
      have_tie_ranks = (set_one + set_two).any? { |rank| rank.is_a?(Float) }

      if have_tie_ranks
        numerator = 0
        squared_differences_set_one = 0
        squared_differences_set_two = 0

        set_one.size.times do |idx|
          local_diff_one = (set_one[idx] - set_one_mean)
          local_diff_two = (set_two[idx] - set_two_mean)

          squared_differences_set_one += local_diff_one ** 2
          squared_differences_set_two += local_diff_two ** 2

          numerator += local_diff_one * local_diff_two
        end

        denominator = Math.sqrt(squared_differences_set_one * squared_differences_set_two)

        puts numerator
        puts denominator
        numerator / denominator.to_f # This is rho or spearman's coefficient.
      else
        sum_squared_differences = set_one.each_with_index.reduce(0) do |memo, (rank_one, index)|
          memo += ((rank_one - set_two[index]) ** 2)
          memo
        end

        numerator = 6 * sum_squared_differences
        denominator = ((set_one.size ** 3) - set_one.size)

        1.0 - (numerator / denominator.to_f) # This is rho or spearman's coefficient.
      end
    end
  end
end
