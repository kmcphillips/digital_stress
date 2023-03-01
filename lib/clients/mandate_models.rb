# frozen_string_literal: true
module MandateModels
  extend self

  QUESTION_MODELS = {
    "dave" => "davinci:ft-quigital:dave-2023-03-01-02-04-08",
    "eliot" => "davinci:ft-quigital:eliot-2023-03-01-04-52-36",
    "kevin" => "davinci:ft-quigital:kevin-2023-03-01-00-22-22",
    "patrick" => "davinci:ft-quigital:patrick-2023-03-01-03-43-38",
  }.freeze

  def question(prompt, name: nil)
    if question_model_for(name)
      model = question_model_for(name)
      name = name.strip.downcase
    else
      name = QUESTION_MODELS.keys.sample
      model = question_model_for(name)
    end

    openai_params = {
      model: model,
      max_tokens: 256,
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 0.2,
      presence_penalty: 0.0,
      stop: [ "###" ],
    }

    result = OpenaiClient.completion(prompt, openai_params)
    completion = result.first.gsub("###", "").strip

    [ name, completion ]
  end

  def question_model_for(name)
    return nil if name.blank?
    QUESTION_MODELS[name.strip.downcase]
  end
end
