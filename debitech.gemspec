# -*- encoding: utf-8 -*-
require File.expand_path('../lib/debitech/version', __FILE__)

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Joakim Kolsjö"]
  s.email         = ["joakim@barsoom.se"]
  s.description   = %q{Library for doing payments using DebiTech (DIBS)}
  s.summary       = %q{Library for doing payments using DebiTech (DIBS)}
  s.homepage      = "https://github.com/barsoom/debitech"
  s.name          = "debitech"
  s.version       = Debitech::VERSION

  s.required_ruby_version = ">= 1.8.7"

  s.add_dependency "debitech_soap"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ["lib"]
end
