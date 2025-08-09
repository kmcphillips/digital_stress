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
    elsif attached_images.one?
      OpenaiClient.chat(query.strip, image_url: attached_images.first.url)
    elsif attached_images.any?
      "Quack! Only one image at a time is supported."
    else
      OpenaiClient.chat(query.strip)
    end
  end
end
