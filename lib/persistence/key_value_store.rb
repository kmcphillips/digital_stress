# frozen_string_literal: true

class KeyValueStore
  attr_reader :redis

  def initialize(datastore_url)
    if datastore_url.starts_with?("redis://")
      @redis = ::Redis.new(url: datastore_url, timeout: 20) # timeout in seconds
    elsif datastore_url.starts_with?("sqlite://")
      @redis = SqliteRedis.new(datastore_url)
    elsif datastore_url.starts_with?("mysql://")
      @redis = MysqlRedis.new(datastore_url)
    else
      @redis = FakeRedis.new
      Global.logger.error("Could not parse redis string. Falling back to FakeRedis.")
    end

    Global.logger.info("KeyValueStore Connected to #{@redis.inspect} (#{datastore_url})")
  end

  def write(key, value, ttl: nil)
    result = @redis.set(format_key(key), value)
    @redis.expire(format_key(key), ttl.to_i) if ttl
    result == "OK"
  end

  def read(key)
    @redis.get(format_key(key))
  end

  def delete(key)
    @redis.del(format_key(key))
  end

  def to_s
    if @redis.is_a?(::Redis)
      "Redis client v#{::Redis::VERSION} `#{@redis.id}`"
    else
      @redis.to_s
    end
  end

  private

  def format_key(key)
    raise "key cannot be blank" if key.blank?
    "digital_stress_#{key}"
  end
end

class FakeRedis
  def initialize
    @db = {}
  end

  def inspect
    "<FakeRedis:#{object_id} in memory size=#{@db.size}>"
  end

  def to_s
    "FakeRedis in memory"
  end

  def set(key, val)
    @db[key.to_s] = {value: val.to_s}
    "OK"
  end

  def get(key)
    obj = @db[key.to_s]

    if obj && (!obj[:expires_at] || (obj[:expires_at] >= Time.now))
      obj[:value]
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

class AbstractSqlRedis
  def initialize
    raise NotImplementedError
  end

  def to_s
    raise NotImplementedError
  end

  def set(key, val)
    @db.transaction do
      @dataset.where(key: key).delete
      @dataset.insert(key: key, value: val.to_s)
    end
    "OK"
  end

  def get(key)
    @dataset.where { timestamp < Time.now.to_i }.delete
    result = @dataset.where(key: key).first
    result[:value] if result
  end

  def del(key)
    @dataset.where(key: key).delete
  end

  def expire(key, seconds)
    @dataset.where(key: key).update(timestamp: Time.now.to_i + seconds.to_i) != 0
  end
end

class SqliteRedis < AbstractSqlRedis
  def initialize(sqlite_url, name = nil)
    @db = Sequel.connect(sqlite_url)
    @db_name = "redis_#{name || "0"}"
    @db.create_table?(@db_name) do
      String :key
      String :value
      Integer :timestamp
    end
    @dataset = @db.from(@db_name)
  end

  def inspect
    "<SqliteRedis:#{object_id} db_name=#{@db_name} #{@db}>"
  end

  def to_s
    "SqliteRedis in `#{File.basename(@db.opts[:database])}`"
  end
end

class MysqlRedis < AbstractSqlRedis
  def initialize(connection_string, name = nil)
    @db = Sequel.connect(connection_string)
    @db_name = "redis_#{name || "0"}"
    @dataset = @db.from(@db_name)
  end

  def inspect
    "<MysqlRedis:#{object_id} db_name=#{@db_name} #{@db}>"
  end

  def to_s
    "MysqlRedis `#{@db.opts[:database]}` at `#{@db.opts[:host]}:#{@db.opts[:port]}`"
  end
end
