# frozen_string_literal: true
module Dedup
  extend self

  FILENAME = "dedup.json"

  def found?(value, namespace:)
    !!cache[format_namespace(namespace).concat(value)]
  end

  def register(value, namespace:)
    cache[format_namespace(namespace).concat(value)] = true
    write_file_cache
    true
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

  def cache
    @cache ||= read_file_cache
  end

  def read_file_cache
    JSON.load(File.read(FILENAME))
  end

  def write_file_cache
    File.write(FILENAME, cache.to_json)
  end

  def format_namespace(namespace)
    Array(namespace).map { |v| (v.presence || "").downcase.strip }.join("::").concat("::")
  end
end
