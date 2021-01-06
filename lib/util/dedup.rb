# frozen_string_literal: true
class Dedup
  CACHE = Lightly.new(dir: "tmp/dedup", life: "1d", hash: true)

  attr_reader :namespace

  def initialize(*namespace_tokens)
    @namespace = namespace_tokens
  end

  def found?(value)
    k = key(value)
    v = CACHE.cached?(k)
    Global.logger.info("[Dedup] found?=#{ v } '#{ k }'")
    v
  end

  def register(value)
    k = key(value)
    Global.logger.info("[Dedup] register '#{ k }'")
    CACHE.save(key(value), value)
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
end
