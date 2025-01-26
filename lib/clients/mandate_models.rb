# frozen_string_literal: true

module MandateModels
  extend self

  QUESTION_MODELS = {
    "dave" => "davinci:ft-quigital:dave-2023-03-01-02-04-08",
    "eliot" => "davinci:ft-quigital:eliot-2023-03-01-04-52-36",
    "kevin" => "davinci:ft-quigital:kevin-2023-03-01-00-22-22",
    "patrick" => "davinci:ft-quigital:patrick-2023-03-01-03-43-38"
  }.freeze

  CHAT_MODELS = {
    "dave" => "davinci:ft-quigital:dave-chat-2023-03-02-15-23-43",
    "eliot" => "davinci:ft-quigital:eliot-chat-2023-03-02-14-34-51",
    "kevin" => "davinci:ft-quigital:kevin-chat-2023-03-02-15-58-41",
    "patrick" => "davinci:ft-quigital:patrick-chat-2023-03-02-16-46-42"
  }

  def question(prompt, name:)
    if question_model_for(name)
      name = name.strip.downcase
      model = question_model_for(name)
    end

    raise "No model found for name: #{name}" unless model

    openai_params = {
      model: model,
      max_tokens: 256,
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 0.2,
      presence_penalty: 0.0,
      stop: ["###"],
      n: 2
    }

    result = OpenaiClient.completion(prompt, openai_params)
    completion = result.map { |r| r.gsub("###", "").strip }.find(&:present?)

    [name, completion]
  end

  def chat(prompt, name:)
    if chat_model_for(name)
      name = name.strip.downcase
      model = chat_model_for(name)
    end

    raise "No model found for name: #{name}" unless model

    openai_params = {
      model: model,
      max_tokens: 256,
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 0.2,
      presence_penalty: 0.0,
      stop: ["###"],
      n: 1
    }

    prompt = "This is a chat message from #{name}:"

    result = OpenaiClient.completion(prompt, openai_params)
    completion = result.map { |r| r.gsub("###", "").strip }.find(&:present?)

    [name, completion]
  end

  def question_model_for(name)
    return nil if name.blank?
    QUESTION_MODELS[name.strip.downcase]
  end

  def chat_model_for(name)
    return nil if name.blank?
    CHAT_MODELS[name.strip.downcase]
  end
end
