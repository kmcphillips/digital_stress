# frozen_string_literal: true

module Flags
  extend self

  def active?(flag, server:)
    !!kv_store.read(key(server: server, flag: flag))
  end

  def activate(flag, server:, seconds: nil)
    kv_store.write(key(server: server, flag: flag), "1", ttl: seconds)
    true
  end

  def deactivate(flag, server:)
    kv_store.delete(key(server: server, flag: flag))
    true
  end

  private

  def key(flag:, server:)
    raise ArgumentError, "server cannot be blank" unless server.present?
    raise ArgumentError, "flag cannot be blank" unless flag.present?
    raise ArgumentError, "flag must be a String or Symbol" unless flag.is_a?(String) || flag.is_a?(Symbol)

    "flag:#{flag}:#{server}"
  end

  def kv_store
    Global.kv
  end
end
