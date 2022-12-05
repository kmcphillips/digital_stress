# frozen_string_literal: true
class AiResponder < BaseResponder
  include ResponderMatcher

  def respond
    respond_match(/kitchen.?noise/i, completion("Play a popular song using only kitchen noises."))
  end

  private

  def completion(prompt)
    OpenaiClient.completion(prompt, openai_params).first.strip
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
