# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "execute_with_rescue_with_airbrake/version"

Gem::Specification.new do |spec|
  spec.name          = "execute_with_rescue_with_airbrake"
  spec.version       = ExecuteWithRescueWithAirbrake::VERSION
  spec.authors       = ["PikachuEXE"]
  spec.email         = ["pikachuexe@gmail.com"]
  spec.summary       = <<-SUMMARY
    The Airbrake adapter plus mixin to be used with `execute_with_rescue`
  SUMMARY
  spec.homepage      = "http://github.com/PikachuEXE/execute_with_rescue_with_airbrake"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "execute_with_rescue", "~> 0.0", ">= 0.0.1"
  spec.add_dependency "airbrake", ">= 4.0.0", "< 5"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "appraisal", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.0"
  spec.add_development_dependency "coveralls", ">= 0.7"
  spec.add_development_dependency "gem-release", ">= 0.7"
  spec.add_development_dependency "rubocop", "~> 0.30"

  spec.required_ruby_version = ">= 2.1.0"

  spec.required_rubygems_version = ">= 1.4.0"
end
