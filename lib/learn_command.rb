# frozen_string_literal: true
class LearnCommand < BaseCommand
  PING_REGEX = /\A<@\!([0-9]+)>\Z/

  class << self
    def persist(datastore:, event:, message:, user_id:)
      # TODO
    end
  end

  def response
    if event.channel.pm?
      "Quack, I can't learn a direct message."
    else
      ping = PING_REGEX.match(params[0])

      if ping
        user_id = ping[1].to_i
        params.shift
        message = params.join(" ")

        Log.info("learning for user##{ user_id }: #{ message }")
      else
        user_id = event.user.id
        message = params.join(" ")

        Log.info("learning for author: #{ message }")
      end

      server = event.server&.name
      channel = event.channel&.name

      if user_id && message.present? && server && channel
        datastore.learn(user_id: user_id, message: message, server: server, channel: channel)
        event.message.react("✅")
      else
        event.message.react("🚫")
      end

      nil
    end
  end
end
