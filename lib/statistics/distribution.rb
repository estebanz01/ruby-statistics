Dir[File.dirname(__FILE__) + '/distribution/**/*.rb'].each {|file| require file }

module Statistics
  module Distribution
  end
end

# If Distribution is not defined, setup alias.
if defined?(Statistics) && !(defined?(Distribution))
  Distribution = Statistics::Distribution
end
