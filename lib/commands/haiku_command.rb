# frozen_string_literal: true
class HaikuCommand < BaseCommand
  def response
    if query.blank?
      "Your input is blank\nI can't compose from nothing\nTry again quack quack"
    else
      "*#{ OpenaiClient.completion(prompt(query), openai_params).first.strip }*"
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
    "Compose a haiku about #{ text.strip.gsub(/[.!?:;]\Z/, "") }."
  end

  def openai_params
    {
      engine: "davinci-instruct-beta-v3",
      max_tokens: 64,
      temperature: 0.9,
      top_p: 1.0,
      frequency_penalty: 0.5,
      presence_penalty: 0.5,
    }
  end
end
