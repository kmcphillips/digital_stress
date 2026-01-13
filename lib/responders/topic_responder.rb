# frozen_string_literal: true

class TopicResponder < BaseResponder
  TOPIC_REGEX = /(?:^|\s)#([-_0-9a-zA-Z]{3,50})(?:$|\s|\.|\?|!)/i

  def channels
    [
      "mandatemandate#general",
      "mandatemandate#dnd",
      "duck-bot-test#testing"
    ].freeze
  end

  def respond
    if (match = TOPIC_REGEX.match(event.message.content))
      topic_name = match[1]
      file = nil

      thread = Thread.new do
        file = OpenaiClient.image_file(image_prompt(topic_name)).first
      end

      begin
        Timeout.timeout(5) do
          event.channel.topic = "Welcome to **##{topic_name}**"
        end
      rescue Timeout::Error
        event.message.react("🐌")
        thread.join
      else
        event.respond("💬 Current topic: **##{topic_name}**")
        event.channel.start_typing
        thread.join
        event.send_file(file, filename: "topic.png") if file
      end

      nil
    end
  end

  private

  IMAGE_PROMPTS = [
    "A cartoonish image matching the topic:",
    "A modern looking banner image for a chat channel named:",
    "A duck holding a sign that says:",
    "A corporate tech company flat styled animated person pointing to the word:",
    "A 90s style image to be used in a chat channel named:",
    "Pixel art for the banner of a chat channel named:",
    "A logo for a chat channel named:",
    "A duck near the word:",
    "A very boring looking duck looking at a sign that says:",
    "Some extreme 80s imagery for a chat channel named:",
    "Typographic and image style of a kid's toy, that involves a duck, and is called:",
    "A hacker aesthetic image for a chat channel named:",
    "A hyper modern sleak logo for a chat channel named:",
    "A very minimalistic logo for a chat channel named:",
    "A stereotypical Canadian image which tastefully includes a duck and the chat channel name:"
  ].freeze

  def image_prompt(topic_name)
    "#{IMAGE_PROMPTS.sample} #{topic_name}"
  end
end
