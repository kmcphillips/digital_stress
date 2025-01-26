# frozen_string_literal: true

class DisclaimerCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.completion(prompt, openai_params).first.strip
  end

  private

  def prompt
    "Write a fine-print disclaimer insulating yourself from liability in the event that a long string of bizarre, nonsensical things happen. Be specific about these things."
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
