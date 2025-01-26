# frozen_string_literal: true

class InsultCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Who should I quacking insult?"
    elsif rand < 0.05 && user.mandate_name
      OpenaiClient.completion(insult_person_prompt(user.mandate_name), openai_params).first.strip
    else
      OpenaiClient.completion(insult_prompt(query), openai_params).first.strip
    end
  end

  private

  def insult_prompt(text)
    "Write a biting and witty insult directed at #{scrub(text)}."
  end

  def insult_person_prompt(name)
    "Write a biting and witty insult directed at #{scrub(name)}, making it clear that you do not care for their attitude."
  end

  def scrub(text)
    text.strip.gsub(/^about /i, "")
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
