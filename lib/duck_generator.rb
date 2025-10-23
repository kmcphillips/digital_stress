# frozen_string_literal: true

module DuckGenerator
  extend self

  MAX_TRAINING_MESSAGES = 18

  def generate(server:, channel:, message:)
    raise "server cannot be blank" unless server.present?
    raise "channel cannot be blank" unless channel.present?
    raise "message cannot be blank" unless message.present?

    training_messages = Learner.random_message(server: server, channel: channel, prevent_recent: false, count: MAX_TRAINING_MESSAGES)

    OpenaiClient.chat(prompt(training_messages, message))&.first
  end

  private

  def prompt(training_messages, message)
    "You are named 'Duck'. You are an outgoing quick witted character that gives brief responses, and punctuates them with a 'Quack!'. Your style is to respond with non sequeturs. Give me only a single line response, not many lines. You are participating in a casual chat with good friends on a Discord server. Reply to the following message:\n\n#{message}\n\nBut very important! Reply in the style of the following messages which are an example of the voice and tone and language you should use (each message is a single line):\n\n#{training_messages.join("\n")}."
  end
end
