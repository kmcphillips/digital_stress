# frozen_string_literal: true
class LearnCommand < BaseCommand
  def response
    if event.channel.pm?
      "Quack, I can't learn a direct message."
    else
      user_id = Pinger.extract_user_id(params[0])

      if user_id
        params.shift
        message = formatted_message(params)

        Log.info("learning for user##{ user_id }: #{ message }")
      else
        user_id = event.user.id
        message = formatted_message(params)

        Log.info("learning for author: #{ message }")
      end

      server = event.server&.name
      channel = event.channel&.name
      message_id = event.message&.id

      if Learner.learn(user_id: user_id, message_id: message_id, message: message, server: server, channel: channel)
        event.message.react("✅")
      else
        event.message.react("🚫")
      end

      nil
    end
  end

  def typing?
    false
  end

  private

  def formatted_message(params)
    message = params.join(" ")
    message = message.strip
    message = message.gsub(/^\"/, "").gsub(/\"$/, "")
    message
  end
end
