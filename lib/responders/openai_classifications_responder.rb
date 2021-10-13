# frozen_string_literal: true
class OpenaiClassificationsResponder < BaseResponder
  def channels
    OpenaiCommand::CHANNELS
  end

  def respond
    return unless OpenaiData.classifying?(server: server, channel: channel)
    return if text.downcase.starts_with?("duck ")

    response = Global.openai_client.classifications(parameters: {
      file: OpenaiData.classifications_file(server: server, channel: channel),
      query: text,
      model: "ada"
    })

    name = response["label"]
    emoji = name_emoji(name)

    event.message.react(emoji) if emoji
  end

  private

  def name_emoji(name)
    case((name || "").downcase)
    when "eliot" then "🇪"
    when "patrick" then "🇵"
    when "kevin" then "🇰"
    when "dave" then "🇩"
    end
  end
end
