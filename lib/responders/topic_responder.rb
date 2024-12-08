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
      file = nil

      thread = Thread.new do
        file = OpenaiClient.image_file(image_prompt(topic_name)).first
      end

      begin
        Timeout::timeout(5) do
          event.channel.topic = "Welcome to **##{ topic_name }**"
        end
      rescue Timeout::Error => e
        event.message.react("🐌")
        thread.join
      else
        event.respond("💬 Current topic: **##{ topic_name }**")
        event.channel.start_typing
        thread.join
        event.send_file(file, filename: "topic.png") if file
      end

      nil
    end
  end

  private

  def image_prompt(topic_name)
    [
      "A cartoonish image matching the topic: #{ topic_name }",
      "A modern looking banner image for a chat channel named: #{ topic_name }",
      "A duck holding a sign that says: #{ topic_name }",
      "A corporate tech company flat styled animated person pointing to the word: #{ topic_name }",
      "A 90s style image to be used in a chat channel named: #{ topic_name }",
      "Pixel art for the banner of a chat channel named: #{ topic_name }",
      "A logo for a chat channel named: #{ topic_name }",
      "A duck near the word: #{ topic_name }",
    ].sample
  end
end
