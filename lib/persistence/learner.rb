# frozen_string_literal: true

module Learner
  extend self

  LEARN_EMOJI = [
    "🦆",
    "duckgame",
    "duckgame_test"
  ].freeze

  ISOLATED_CHANNELS = [
    "duck-bot-test#restricted",
    "mandatemandate#wives",
    "mandatemandate#mandate_totality"
  ]

  def learn_emoji?(emoji)
    LEARN_EMOJI.include?(emoji)
  end

  def learn(user_id:, message_id:, message:, server:, channel:, time: nil)
    if user_id && message.present? && server && channel
      table.insert(
        user_id: user_id,
        message: message,
        server: server,
        channel: channel,
        message_id: message_id,
        timestamp: Formatter.parse_timestamp(time)
      )

      true
    else
      false
    end
  end

  def unlearn(message_id:)
    table.where(message_id: message_id).delete
  end

  def all(server:)
    table
      .where(server: server)
      .order(:id)
      .all
  end

  def count(server:)
    table
      .where(server: server)
      .count
  end

  def last(server:)
    table
      .where(server: server)
      .order(:id)
      .last
  end

  def random(server:, channel:, prevent_recent: false, count: nil)
    raise "server cannot be blank" unless server.present?
    raise "count must be a positive integer" if count.present? && count <= 0
    raise "cannot prevent_recent and return more than one record" if prevent_recent && count.present? && count > 1 # This is arbitrary but removes complication

    scope = table
      .where(server: server)
      .order(Sequel.lit("RAND()"))

    if channel.present? && ISOLATED_CHANNELS.include?("#{server}##{channel}")
      scope = scope.exclude(id: recent_ids(server: server, channel: channel)) if prevent_recent

      scope = scope.where(channel: channel)
    else
      scope = scope.exclude(id: recent_ids(server: server, channel: nil)) if prevent_recent

      ISOLATED_CHANNELS.each do |isolated_server_channel|
        isolated_server, isolated_channel = isolated_server_channel.split("#")
        scope = scope.exclude(channel: isolated_channel) if server == isolated_server
      end
    end

    if count && count > 1
      scope.limit(count).all
    else
      record = scope.first
      record_recent(record, server: server, channel: channel) if prevent_recent && record
      record
    end
  end

  def random_message(server:, channel:, prevent_recent: false, count: nil)
    result = random(server: server, channel: channel, prevent_recent: prevent_recent, count: count)

    if result.is_a?(Array)
      result.compact.map { |r| r[:message].to_s }
    elsif result
      result[:message].to_s
    end # else nil
  end

  def find(id)
    raise "id cannot be blank" unless id.present?
    table.where(id: id).first
  end

  def update(id, message:)
    raise "id cannot be blank" unless id.present?
    table.where(id: id).update(message: message)
  end

  def delete(id)
    raise "id cannot be blank" unless id.present?
    table.where(id: id).delete
  end

  private

  def table
    Global.db[:learned]
  end

  def kv_store
    Global.kv
  end

  def recent_ids(server:, channel:)
    JSON.parse(kv_store.read(recent_key(server: server, channel: channel)))
  rescue
    []
  end

  def record_recent(record, server:, channel:)
    ids = recent_ids(server: server, channel: channel)
    ids = ids.unshift(record[:id])
    ids = ids[0...recent_max_length(server: server, channel: channel)]

    kv_store.write(recent_key(server: server, channel: channel), ids.to_json)

    true
  end

  def recent_max_length(server:, channel:)
    [(count(server: server) / 3), 1].max
  end

  def recent_key(server:, channel:)
    if channel.present?
      "learner-recent-ids-isolated-#{server}-#{channel}"
    else
      "learner-recent-ids-#{server}"
    end
  end
end
