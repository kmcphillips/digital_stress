# frozen_string_literal: true
module OpenaiClient
  extend self

  def default_model
    "text-davinci-003"
  end

  def models
    Global.openai_client.models.list["data"].map { |m| m["id"] }
  end

  def completion(prompt, openai_params={})
    parameters = openai_params.symbolize_keys
    Global.logger.info("[OpenaiClient][completion] request #{ parameters } prompt:\n#{ prompt }")
    raise "[OpenaiClient][completion] passed in `engine` param, use `model` instead" if parameters.key?(:engine)
    parameters[:model] ||= OpenaiClient.default_model
    parameters[:prompt] = prompt
    response = Global.openai_client.completions(parameters: parameters)
    Global.logger.info("[OpenaiClient][completion] response #{ response.inspect }")
    if response.success?
      result = response.parsed_response["choices"].map{ |c| c["text"] }
      raise "[OpenaiClient][completion] request #{ parameters } prompt:\n#{ prompt } gave a blank result: #{ response.parsed_response }" if result.blank?
      result
    else
      error_message = response.parsed_response["error"] rescue nil
      ":bangbang: OpenAI returned error HTTP #{ response.code } #{ error_message }"
    end
  end

  def image(prompt, openai_params={})
    parameters = openai_params.symbolize_keys
    Global.logger.info("[OpenaiClient][image] request #{ parameters } prompt:\n#{ prompt }")
    parameters[:prompt] = prompt
    response = Global.openai_client.images.generate(parameters: parameters)
    Global.logger.info("[OpenaiClient][image] response #{ response.inspect }")
    if response.success?
      if parameters[:response_format] == "b64_json"
        result = response.parsed_response["data"].map{ |c| c["b64_json"] }
        raise "[OpenaiClient][image] request #{ parameters } prompt:\n#{ prompt } gave a blank b64_json result: #{ response.parsed_response }" if result.blank?
        result
      else
        result = response.parsed_response["data"].map{ |c| c["url"] }
        raise "[OpenaiClient][image] request #{ parameters } prompt:\n#{ prompt } gave a blank url result: #{ response.parsed_response }" if result.blank?
        result
      end
    else
      error_message = response.parsed_response["error"] rescue nil
      ":bangbang: OpenAI returned error HTTP #{ response.code } #{ error_message }"
    end
  end

  def image_file(prompt, openai_params={})
    parameters = openai_params.symbolize_keys.merge(response_format: "b64_json")
    image(prompt, parameters).map do |b64_json|
      file = Tempfile.create(["dalle", ".png"], binmode: true)
      file.write(Base64.decode64(b64_json))
      file.rewind
      file
    end
  end
end
