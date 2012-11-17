require 'redis'
REDIS_DB_ENVIRONMENTS = {
  'production'    => 0,
  :production     => 0,

  'development'   => 1,
  :'development'  => 1,

  'test'          => 2,
  :test           => 2
}

# ensure ENV['RACK_ENV'] is set to 'test', 'development', or 'production 'in order to select a database for the running environment
REDIS_URI = ENV["REDISTOGO_URL"] || "redis://localhost:6379/"
ENV["RACK_ENV"] = (ENV["REDISTOGO_URL"].nil? ? "development" : "production" ) if ENV["RACK_ENV"].nil?
REDIS_DB = REDIS_DB_ENVIRONMENTS[ ENV["RACK_ENV"] ]

uri = URI.parse( REDIS_URI )


REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password) rescue nil
REDIS.select REDIS_DB unless REDIS.nil?

puts "!!!\n!!! redis server is not running on #{uri}\n!!!" if REDIS.nil?