require 'mongoid' # mongoid configuration:
MONGO_URI = ENV['MONGOLAB_URI'] || ENV['MONGOHQ_URL']
ENV["RACK_ENV"] = MONGO_URI.nil? ? "development" :  "production"
Mongoid.load!("lib/config/mongoid.yml")
