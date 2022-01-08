# frozen_string_literal: true
class ImagineCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-imagine something"
    else
      OpenaiClient.completion(prompt(query), openai_params)
    end
  end

  private

  def prompt(text)
    "In a couple sentences, describe what #{ text.strip.gsub(/[.!?:;]\Z/, "") } would be like."
  end

  def openai_params
    {
      engine: "davinci-instruct-beta-v3",
      max_tokens: rand(120..256),
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 0.4,
      presence_penalty: 0.4,
    }
  end
end
