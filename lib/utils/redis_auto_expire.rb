# This class implements a cache with simple delegation to the Redis store, but
# when it creates a key/value pair, it also sends an EXPIRE command with a TTL.
# It should be fairly simple to do the same thing with Memcached.
class RedisAutoExpire
  def initialize(store, ttl=86400)
    @store = store
    @ttl = ttl
  end

  def keys
    @store.keys
  end

  def del(key)
    @store.del(key)
  end

  def [](key)
    @store[key]
  end

  def []=(key, value)
    @store[key]= value
    @store.expire(key, @ttl)
  end

end
