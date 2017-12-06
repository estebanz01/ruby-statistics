module Statistics
  module StatisticalTest
    class WilcoxonRankSumTest
      def rank(elements)
        elements.sort.each_with_index.map do |element, index|
          { element => (index + 1) }
        end
      end

      # Steps to perform the calculation are based on http://www.mit.edu/~6.s085/notes/lecture5.pdf
      def perform(alpha, group_one, group_two)
        # Size for each group
        n1, n2 = group_one.size, group_two.size

        # Rank all data
        total_ranks = rank(group_one + group_two)

        # sum rankings per group
        r1 = ranked_sum_for(group_one)
        r2 = ranked_sum_for(group_two)

        # calculate U statistic
        u1 = r1 - (n1 * (n1 + 1)/2.0 )
        u1 = r2 - (n2 * (n2 + 1)/2.0 )

        u_statistic = [u1, u2].min

        median_u = (n1 * n2)/2.0
        std_u = Math.sqrt((n1 * n2 * (n1 + n2 + 1))/12.0)
      end

      private def ranked_sum_for(group)
        # sum rankings per group
        group.reduce(0) do |memo, element|
          rank_of_element = total_ranks.detect { |ranked| ranked[:element] == element }
          memo += rank_of_element[:score]
        end
      end

      private def resolve_ties(group, rankings)
      end
    end
  end
end
