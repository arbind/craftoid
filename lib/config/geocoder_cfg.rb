require 'geocoder' # configure geocoder to use redis:

GEOCODER_CACHE_TTL = 86400 # (60s * 60m * 24h)  # +++ TODO move TTL for geo cache into configs

geocoder_config = {
  lookup: :google,
  cache: RedisAutoExpire.new(REDIS, GEOCODER_CACHE_TTL),
  cache_prefix: "gO:" # gee-oooh :)
}

Geocoder.configure geocoder_config