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

  def random(server:)
    table
      .where(server: server)
      .order(Sequel.lit('RANDOM()'))
      .first
  end

  def random_message(server:)
    result = random(server: server)
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
    DB[:learned]
  end
end
