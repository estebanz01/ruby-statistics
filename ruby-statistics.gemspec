# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby-statistics/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby-statistics"
  spec.version       = RubyStatistics::VERSION
  spec.authors       = ["esteban zapata"]
  spec.email         = ["ruby@estebanz.email"]

  spec.summary       = %q{A ruby gem for som specific statistics. Inspired by the jStat js library.}
  spec.description   = %q{This gem is intended to accomplish the same purpose as jStat js library:
                          to provide ruby with statistical capabilities without the need
                          of a statistical programming language like R or Octave. Some functions
                          and capabilities are an implementation from other authors and are
                          referenced properly in the class/method.}
  spec.homepage      = "https://github.com/estebanz01/ruby-statistics"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Minimum required ruby version
  spec.required_ruby_version = '>= 3.0'

  spec.add_development_dependency "rake", '~> 13.0', '>= 12.0.0'
  spec.add_development_dependency "rspec", '~> 3.13', '>= 3.10.0'
  spec.add_development_dependency 'byebug', '~> 11.1', '>= 11.1.0'
  spec.add_development_dependency 'pry', '~> 0.14', '>= 0.14.0'
  spec.add_development_dependency 'bigdecimal', '~> 3.1', '>= 3.1.9'
end
