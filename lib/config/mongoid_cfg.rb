require 'mongoid' # mongoid configuration:

# ensure ENV['RACK_ENV'] is set so Mongoid.load! can choose the right configs
MONGO_URI = ENV['MONGOLAB_URI'] || ENV['MONGOHQ_URL']
unless ENV["RACK_ENV"]
  ENV["RACK_ENV"] = MONGO_URI.nil? ? "development" :  "production"
end

Mongoid.logger.level = Logger::INFO
# Mongoid.logger.level = Logger::DEBUG

Mongoid.load!("lib/config/mongoid.yml")
