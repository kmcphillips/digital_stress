# frozen_string_literal: true
module Learner
  extend self

  LEARN_EMOJI = [
    "🦆",
    "duckgame",
    "duckgame_test",
  ].freeze

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
        timestamp: Formatter.parse_timestamp(time),
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

  def random(server:, prevent_recent: false)
    scope = table
      .where(server: server)
      .order(Sequel.lit('RANDOM()'))

    scope = scope.exclude(id: recent_ids(server: server)) if prevent_recent

    record = scope.first
    record_recent(record, server: server) if record

    record
  end

  def random_message(server:, prevent_recent: false)
    result = random(server: server, prevent_recent: prevent_recent)
    result[:message] if result
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

  def recent_ids(server:)
    ids = JSON.parse(kv_store.read(recent_key(server: server))) rescue []
    ids
  end

  def record_recent(record, server:)
    ids = recent_ids(server: server)
    ids = ids.unshift(record[:id])
    ids = ids[0...recent_max_length(server: server)]

    kv_store.write(recent_key(server: server), ids.to_json)

    true
  end

  def recent_max_length(server:)
    [ (count(server: server) / 3), 1 ].max
  end

  def recent_key(server:)
    "learner-recent-ids-#{ server }"
  end
end
