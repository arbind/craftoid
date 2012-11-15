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

  gem.add_runtime_dependency 'uri'
  gem.add_runtime_dependency 'redis'
  gem.add_runtime_dependency 'geocoder'
  gem.add_runtime_dependency 'mongoid', '2.4.8'
  gem.add_runtime_dependency 'bson_ext'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
