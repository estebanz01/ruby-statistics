# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "statistics/version"

Gem::Specification.new do |spec|
  spec.name          = "statistics"
  spec.version       = Statistics::VERSION
  spec.authors       = ["esteban zapata"]
  spec.email         = ["estebanz01@outlook.com"]

  spec.summary       = %q{A ruby gem for som specific statistics. A bad port of jStat js library.}
  spec.description   = %q{This gem is intended to do the same job as jStat js library. The main
                          idea is to provide ruby with statistical capabilities without the need
                          of a statistical programming language like R or Octave.}
  spec.homepage      = "https://github.com/estebanz01/ruby-statistics"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency 'descriptive_statistics'
end
