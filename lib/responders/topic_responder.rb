# frozen_string_literal: true
class TopicResponder < BaseResponder
  TOPIC_REGEX = /(?:^|\s)#([-_0-9a-zA-Z]{3,20})(?:$|\s|\.|\?|\!)/i

  def channels
    [
      "mandatemandate#general",
      "duck-bot-test#testing",
    ].freeze
  end

  def respond
    if match = TOPIC_REGEX.match(event.message.content)
      topic_name = match[1]
      message = "💬 Current topic: **##{ topic_name }**"
      topic = "Welcome to **##{ topic_name }**"

      event.channel.topic = topic
      event.channel.start_typing
      event.respond(message)
    end
  end
end
