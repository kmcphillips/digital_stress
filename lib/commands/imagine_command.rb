# frozen_string_literal: true
class ImagineCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-imagine something"
    else
      OpenaiClient.completion(prompt(query), openai_params)
    end
  end

  def after(message:)
    if message
      Recorder.set_againable(
        command_class: self.class.name,
        query: query.strip,
        query_user_id: event.author.id,
        query_message_id: event.message.id,
        response_user_id: message.author.id,
        response_message_id: message.id,
        server: server,
        channel: channel,
      )
    end
  end

  private

  def prompt(text)
    "In a couple sentences, describe #{ tone } what #{ text.strip.gsub(/[.!?:;]\Z/, "") } would be like."
  end

  def openai_params
    {
      engine: "davinci-instruct-beta-v3",
      max_tokens: rand(120..256),
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 1.8,
      presence_penalty: 0.4,
    }
  end

  def tone
    [
      "in a sarcastic tone",
      "in an exaggerated tone",
      "in a funny and sarcastic way",
      "using big words",
      "in an excited way",
      "enthusiastically",
      "critically",
    ].sample
  end
end
