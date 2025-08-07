# frozen_string_literal: true

class OpenaiChatCommand < BaseSubcommand
  include AfterRecorderStrikethroughAgainable

  CHANNELS = [
    "mandatemandate",
    "duck-bot-test"
  ].freeze

  def channels
    CHANNELS
  end

  def response
    if query.blank?
      "Quack! Gotta say something."
    else
      OpenaiClient.chat(query.strip)
    end
  end
end
