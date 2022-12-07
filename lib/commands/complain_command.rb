# frozen_string_literal: true
class ComplainCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.completion(prompt(query), openai_params).first.strip
  end

  private

  def prompt(text)
    if text.blank?
      "Humorously complain about a bizarre, gross, nonsensical problem, but give it a positive spin at the very end."
    else
      text = "about #{ text.strip }" unless text.strip.downcase.start_with?("about")
      "Humorously complain #{ text }, but give it a positive spin at the very end."
    end
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
