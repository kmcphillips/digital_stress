# frozen_string_literal: true
module OpenaiClient
  extend self

  def default_engine
    "text-davinci-003"
  end

  def default_model
    default_engine
  end

  def models
    Global.openai_client.models.list["data"].map { |m| m["id"] }
  end

  def engines
    models
  end

  def completion(prompt, openai_params)
    parameters = openai_params.symbolize_keys
    Global.logger.info("[OpenaiClient] request #{ parameters } prompt:\n#{ prompt }")
    engine = parameters.delete(:engine).presence || OpenaiClient.default_engine
    parameters[:prompt] = prompt
    response = Global.openai_client.completions(engine: engine, parameters: parameters)
    Global.logger.info("[OpenaiClient] response #{ response.inspect }")
    result = response.parsed_response["choices"].map{ |c| c["text"] }
    raise "Got a blank result: #{ response.parsed_response }" if result.blank?
    result
  end
end
