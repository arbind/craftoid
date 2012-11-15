require 'uri'
require 'config/redis_cfg'
require 'config/mongoid_cfg'
require 'config/geocoder_cfg' # depends on redis
require "mixins/geo_aliases"
require "models/craft"
require "models/web_craft/web_craft"
require "models/web_craft/yelp_craft"
require "models/web_craft/twitter_craft"
require "models/web_craft/facebook_craft"
require "models/web_craft/website_craft"

def clear_geocoder_cache
  Geocoder.cache.expire(:all) # expire all cached results
end

# Load gem
require "craftoid/version"
module Craftoid
end
