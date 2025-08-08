# frozen_string_literal: true

class CatCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.chat("Write a short, humorous monologue about cat problems using only cat sounds.", openai_params).first.strip
  end

  private

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
