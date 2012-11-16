# setup for test environment
ENV['RACK_ENV'] = 'test'

# set up test coverage
require 'simplecov'
SimpleCov.start do
  minimum_coverage 100
end

require 'Craftoid'

# start fresh before each test
Mongoid.purge!
#+++ TODO - be sure to select test database for redis 