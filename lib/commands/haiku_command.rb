# frozen_string_literal: true
class HaikuCommand < BaseCommand
  def response
    if query.blank?
      "Your input is blank\nI can't compose from nothing\nTry again quack quack"
    else
      "*#{ OpenaiClient.completion(prompt(query), openai_params).strip }*"
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
