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

  def learn(user_id:, message_id: nil, message:, server:, channel:, time: nil)
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

  def random(server:)
    result = table
      .where(server: server)
      .order(Sequel.lit('RANDOM()'))
      .first

    result[:message] if result
  end

  def all(server:)
    table
      .where(server: server)
      .all
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
    DB[:learned]
  end
end
