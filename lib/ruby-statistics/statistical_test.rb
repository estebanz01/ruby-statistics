Dir[File.dirname(__FILE__) + '/statistical_test/**/*.rb'].each {|file| require file }

module RubyStatistics
  module StatisticalTest
  end
end

# If StatisticalTest is not defined, setup alias.
if defined?(RubyStatistics) && !(defined?(StatisticalTest))
  StatisticalTest = RubyStatistics::StatisticalTest
end
