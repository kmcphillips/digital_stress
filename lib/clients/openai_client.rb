# frozen_string_literal: true
module OpenaiClient
  extend self

  def completion(prompt, openai_params)
    parameters = openai_params.symbolize_keys
    engine = parameters.delete(:engine).presence || "davinci"
    parameters[:prompt] = prompt
    response = Global.openai_client.completions(engine: engine, parameters: parameters)
    Global.logger.info("[OpenaiClient] response #{ response.inspect }")
    result = response.parsed_response["choices"].map{ |c| c["text"] }
    raise "Got a blank result: #{ response.parsed_response }" if result.blank?
    result
  end
end
