# frozen_string_literal: true
class DefineCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Define what?"
    else
      if rand < 0.2 && user.mandate_name
        OpenaiClient.completion(wrong_prompt(query), openai_params).first.strip
      else
        OpenaiClient.completion(prompt(query), openai_params).first.strip
      end
    end
  end

  private

  def prompt(text)
    "Give the definition of: #{ text.strip }"
  end

  def wrong_prompt(text)
    "Give an amusing but incorrect definition of: #{ text.strip }"
  end

  def openai_params
    {
      model: OpenaiClient.default_model,
      max_tokens: 256,
      temperature: 1.0,
      top_p: 1.0,
      frequency_penalty: 0.0,
      presence_penalty: 0.0,
    }
  end
end
