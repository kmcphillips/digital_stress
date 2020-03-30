# frozen_string_literal: true
class LearnCommand < BaseCommand
  def response
    if event.channel.pm?
      "Quack, I can't learn a direct message."
    else
      message = params.join(" ")
      datastore.learn(user_id: event.user.id, message: message, server: event.server.name, channel: event.channel.name)
      event.message.react("✅")
      nil
    end
  end
end
