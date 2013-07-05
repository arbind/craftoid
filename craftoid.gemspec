# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'craftoid/version'

Gem::Specification.new do |gem|
  gem.name          = "craftoid"
  gem.version       = Craftoid::VERSION
  gem.authors       = ["Arbind"]
  gem.email         = ["arbind.thakur@gmail.com"]
  gem.description   = "Domain model of someone's craft and their webcrafts"
  gem.summary       = ""
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib", "lib/config"]

  gem.add_development_dependency 'redis', '~> 3.0.4'
  gem.add_development_dependency 'geocoder', '~> 1.1.8'
  gem.add_development_dependency 'mongoid', '~> 3.1.4'
  gem.add_development_dependency 'rake', '~> 10.1.0'
  gem.add_development_dependency 'rspec', '~> 2.13.0'
  gem.add_development_dependency 'simplecov', '0.7.1'
end
