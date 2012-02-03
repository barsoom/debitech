# -*- encoding: utf-8 -*-
require File.expand_path('../lib/debitech/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joakim Kolsjö"]
  gem.email         = ["joakim@barsoom.se"]
  gem.description   = %q{Library for doing payments using DebiTech (DIBS)}
  gem.summary       = %q{Library for doing payments using DebiTech (DIBS)}
  gem.homepage      = "https://github.com/barsoom/debitech"
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.name          = "debitech"
  gem.require_paths = ["lib"]
  gem.version       = Debitech::VERSION
  gem.add_dependency "debitech_soap"
  gem.add_development_dependency "rake"
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
end
