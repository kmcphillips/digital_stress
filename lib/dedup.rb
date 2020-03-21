# frozen_string_literal: true
module Dedup
  extend self

  CACHE = Lightly.new(dir: "tmp/dedup", life: "1d", hash: true)

  def found?(value, namespace:)
    CACHE.cached?(key(value, namespace: namespace))
  end

  def register(value, namespace:)
    CACHE.save(key(value, namespace: namespace), value)
  end

  def list(values, namespace:)
    values.each do |value|
      if !found?(value, namespace: namespace)
        register(value, namespace: namespace)

        return value
      end
    end

    nil
  end

  private

  def key(value, namespace:)
    Array(namespace).map { |v| (v.presence || "").downcase.strip }.join("__").concat("__").concat(value)
  end
end
