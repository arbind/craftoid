class RedisAutoExpire
  def initialize(store, ttl=86400)
    @store = store
    @ttl = ttl
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end

  def [](url)
    @store[url]
  end

  def []=(url, value)
    @store[url]= value
    @store.expire(url, @ttl)
  end

end
