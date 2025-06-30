# frozen_string_literal: true

class Dedup
  CACHE_LENGTH_SECONDS = 1.day.to_i

  attr_reader :namespace

  def initialize(*namespace_tokens)
    @namespace = namespace_tokens
  end

  def found?(value)
    result = !!kv_store.read(hashed_key(value))
    Global.logger.info("[Dedup] found?=#{result} '#{readable_key(value)}'")
    result
  end

  def register(value)
    Global.logger.info("[Dedup] register '#{readable_key(value)}'")
    !!kv_store.write(hashed_key(value), "1", ttl: CACHE_LENGTH_SECONDS)
  end

  def list(values)
    values.each do |value|
      if !found?(value)
        register(value)
        return value
      end
    end

    nil
  end

  private

  def readable_key(value)
    Array(namespace).map { |v| (v.presence || "").downcase.strip }.join("__").concat("__").concat(value)
  end

  def hashed_key(value)
    Array(namespace).map { |v| (v.presence || "").downcase.strip }.join("__").concat("__").concat(Digest::SHA256.hexdigest(value))
  end

  def kv_store
    Global.kv
  end
end
