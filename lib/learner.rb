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

  def get_random(server:)
    result = table
      .order(Sequel.lit('RANDOM()'))
      .first(server: server)

    result[:message] if result
  end

  private

  def table
    DB[:learned]
  end

  # def learned(user_id: nil, server:)
  #   result = if user_id
  #     @db.execute("SELECT id, message, user_id, message_id FROM learned WHERE server = ? AND user_id = ?", [server, user_id])
  #   else
  #     @db.execute("SELECT id, message, user_id, message_id FROM learned WHERE server = ?", [server])
  #   end

  #   result.to_a
  # end

  # def find_learned(id)
  #   @db.execute("SELECT message FROM learned WHERE id = ?", [id]).to_a.first.first
  # end

  # def update_learned(id, message)
  #   @db.execute("UPDATE learned SET message = ? WHERE id = ?", [message, id])
  # end

  # def delete_learned(id)
  #   @db.execute("DELETE FROM learned WHERE id = ?", [id])
  # end
end
