# frozen_string_literal: true
class KeyValueStore
  attr_reader :redis

  def initialize(redis_url)
    begin
      @redis = Redis.new(url: redis_url)
      @redis.echo("Connected to redis #{ redis_url }")
    rescue Redis::BaseError => e
      @redis = FakeRedis.new
    end

    puts "[KeyValueStore Connected to #{ @redis.inspect }"
  end

  def write(key, value, ttl=nil)
    result = @redis.set(format_key(key), value)
    @redis.expire(format_key(key), ttl) if ttl
    result == "OK"
  end

  def read(key)
    @redis.get(format_key(key))
  end

  def delete(key)
    @redis.del(format_key(key))
  end

  private

  def format_key(key)
    raise "key cannot be blank" if key.blank?
    "digital_stress_#{ key }"
  end
end

class FakeRedis
  def initialize
    @db = {}
  end

  def inspect
    "<FakeRedis:#{ object_id } in memory size=#{ @db.size }>"
  end

  def to_s
    inspect
  end

  def set(key, val)
    @db[key.to_s] = { value: val.to_s }
    "OK"
  end

  def get(key)
    obj = @db[key.to_s]

    if obj && (!obj[:expires_at] || (obj[:expires_at] >= Time.now))
      obj[:value]
    else
      nil
    end
  end

  def del(key)
    @db.delete(key) ? 1 : 0
  end

  def expire(key, seconds)
    if @db.key?(key.to_s)
      @db[key.to_s][:expires_at] = Time.now + seconds.to_i.seconds
      true
    else
      false
    end
  end
end
