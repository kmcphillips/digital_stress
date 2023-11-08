# frozen_string_literal: true
class TopicResponder < BaseResponder
  TOPIC_REGEX = /(?:^|\s)#([-_0-9a-zA-Z]{3,50})(?:$|\s|\.|\?|\!)/i

  def channels
    [
      "mandatemandate#general",
      "mandatemandate#dnd",
      "duck-bot-test#testing",
    ].freeze
  end

  def respond
    if match = TOPIC_REGEX.match(event.message.content)
      topic_name = match[1]

      begin
        Timeout::timeout(5) do
          event.channel.topic = "Welcome to **##{ topic_name }**"
        end
      rescue Timeout::Error => e
        event.message.react("🐌")
      else
        event.channel.start_typing
        event.respond("💬 Current topic: **##{ topic_name }**")
      end
    end
  end
end
