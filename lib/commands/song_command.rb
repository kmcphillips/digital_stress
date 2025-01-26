# frozen_string_literal: true

class SongCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "What should we sing about?"
    else
      OpenaiClient.completion(prompt(query), openai_params).first.strip
    end
  end

  private

  def prompt(text)
    text = "about #{text.strip}" unless text.strip.downcase.start_with?("about")
    "Write the lyrics to the chorus of a hit song #{text.strip}."
  end

  def openai_params
    {
      model: OpenaiClient.default_model,
      max_tokens: 256,
      temperature: 1.0,
      top_p: 1.0,
      frequency_penalty: 0.0,
      presence_penalty: 0.0
    }
  end
end
