# frozen_string_literal: true
class InsultCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Who should I quacking insult?"
    else
      if rand < 0.05 && user.mandate_name
        OpenaiClient.completion(insult_person_prompt(user.mandate_name), openai_params).first.strip
      else
        OpenaiClient.completion(insult_prompt(query), openai_params).first.strip
      end
    end
  end

  private

  def insult_prompt(text)
    "Write a biting and witty insult directed at #{ text.strip }."
  end

  def insult_person_prompt(name)
    "Write a biting and witty insult directed at #{ name.strip }, making it clear that you do not care for their attitude."
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
