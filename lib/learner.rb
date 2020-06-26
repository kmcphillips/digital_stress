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

  def learn(user_id:, message:, server:, channel:) # TODO event_id
    if user_id && message.present? && server && channel
      LegacyDatastore.learn(
        user_id: user_id,
        message: message,
        server: server,
        channel: channel,
      )

      true
    else
      false
    end
  end
end
