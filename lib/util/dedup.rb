# frozen_string_literal: true
class Dedup
  CACHE_LENGTH_SECONDS = 1.day.to_i

  attr_reader :namespace

  def initialize(*namespace_tokens)
    @namespace = namespace_tokens
  end

  def found?(value)
    k = key(value)
    v = !!kv_store.read(k)
    Global.logger.info("[Dedup] found?=#{ v } '#{ k }'")
    v
  end

  def register(value)
    k = key(value)
    Global.logger.info("[Dedup] register '#{ k }'")
    !!kv_store.write(key(value), value, ttl: CACHE_LENGTH_SECONDS)
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

  def key(value)
    Array(namespace).map { |v| (v.presence || "").downcase.strip }.join("__").concat("__").concat(value)
  end

  def kv_store
    Global.kv
  end
end
