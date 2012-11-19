require 'mongoid' # mongoid configuration:

# ensure ENV['RACK_ENV'] is set so Mongoid.load! can load the right configs
MONGO_URI = ENV['MONGOLAB_URI'] || ENV['MONGOHQ_URL']
ENV["RACK_ENV"] = (MONGO_URI.nil? ? "development" : "production" ) if ENV["RACK_ENV"].nil?

Mongoid.logger ||=  Logger.new($stdout, :warn)
Mongoid.logger.level = Logger::INFO
# Mongoid.logger.level = Logger::DEBUG

# +++ TODO see an app using this gem has already specifieda config file (maybe? at config/mongoid.yml)
config_mongoid_yml = File.join(File.dirname(File.expand_path(__FILE__)), 'mongoid.yml') 
Mongoid.load!(config_mongoid_yml)
