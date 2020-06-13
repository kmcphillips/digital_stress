# frozen_string_literal: true
class KeyValueStore
  attr_reader :redis

  def initialize(datastore_url)
    if datastore_url.starts_with?("redis://")
      begin
        @redis = Redis.new(url: datastore_url)
        @redis.echo("Connected to redis #{ datastore_url }")
      rescue Redis::BaseError => e
        puts e.inspect
        @redis = FakeRedis.new
      end
    elsif datastore_url.ends_with?(".sqlite3")
      @redis = SqliteRedis.new(datastore_url)
    else
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

class SqliteRedis
  def initialize(sqlite_file, name=nil)
    @db = Sequel.sqlite(sqlite_file + "asdf")
    @db_name = "redis_#{ name || '0' }"
    @db.create_table?(@db_name) do
      String :key
      String :value
      Integer :timestamp
    end
    @dataset = @db.from(@db_name)
  end

  def inspect
    "<SqliteRedis:#{ object_id } db_name=#{ @db_name } #{ @db }>"
  end

  def to_s
    inspect
  end

  def set(key, val)
    del(key)
    @dataset.insert(key: key, value: val)
    "OK"
  end

  def get(key)
    @dataset.where{ timestamp < Time.now.to_i }.delete
    result = @dataset.where(key: key).first
    result[:value] if result
  end

  def del(key)
    @dataset.where(key: key).delete
  end

  def expire(key, seconds)
    c = @dataset.where(key: key).update(timestamp: Time.now.to_i + seconds)
    c != 0
  end
end
