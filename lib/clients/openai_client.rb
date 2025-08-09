# frozen_string_literal: true

module OpenaiClient
  extend self

  class Error < StandardError; end

  def default_model
    "gpt-5"
  end

  def default_image_model
    "dall-e-3"
  end

  def models
    Global.openai_client.models.list["data"].map { |m| m["id"] }
  end

  def chat(prompt, openai_params = {})
    parameters = openai_params.symbolize_keys
    Global.logger.info("[OpenaiClient][chat] request #{parameters} prompt:\n#{prompt}")
    raise Error, "[OpenaiClient][chat] passed in `engine` param, use `model` instead" if parameters.key?(:engine)
    parameters[:model] ||= OpenaiClient.default_model
    parameters[:messages] = [{role: "user", content: prompt}]
    response = Global.openai_client.chat(parameters: parameters)
    Global.logger.info("[OpenaiClient][chat] response #{response.inspect}")
    if !response.key?("error")
      result = response["choices"].map { |c| c.dig("message", "content") }
      raise Error, "[OpenaiClient][chat] request #{parameters} prompt:\n#{prompt} gave a blank result: #{response}" if result.blank?
      result
    else
      error_message = begin
        response["error"]
      rescue
        nil
      end
      raise Error, ":bangbang: OpenAI returned error: #{error_message}"
    end
  end

  def image(prompt, openai_params = {})
    parameters = openai_params.symbolize_keys
    Global.logger.info("[OpenaiClient][image] request #{parameters} prompt:\n#{prompt}")
    parameters[:model] ||= OpenaiClient.default_image_model
    parameters[:prompt] = prompt
    parameters[:size] ||= "1792x1024"
    response = Global.openai_client.images.generate(parameters: parameters)
    Global.logger.info("[OpenaiClient][image] response #{response.inspect}")
    if !response.key?("error")
      if parameters[:response_format] == "b64_json"
        result = response["data"].map { |c| c["b64_json"] }
        if result.blank?
          raise Error, "[OpenaiClient][image] request #{parameters} prompt:\n#{prompt} gave a blank b64_json result: #{response}"
        end
      else
        result = response["data"].map { |c| c["url"] }
        if result.blank?
          raise Error, "[OpenaiClient][image] request #{parameters} prompt:\n#{prompt} gave a blank url result: #{response}"
        end
      end
      result
    else
      error_message = begin
        response["error"]
      rescue
        nil
      end
      raise Error, ":bangbang: OpenAI returned error: #{error_message}"
    end
  end

  def image_file(prompt, openai_params = {})
    parameters = openai_params.symbolize_keys.merge(response_format: "b64_json")
    image(prompt, parameters).map do |b64_json|
      file = Tempfile.create(["dalle", ".png"], binmode: true)
      file.write(Base64.decode64(b64_json))
      file.rewind
      file
    end
  end

  def responses(prompt, image_url: nil, previous_response_id: nil, parameters: {})
    parameters = parameters.symbolize_keys
    parameters[:model] ||= OpenaiClient.default_model
    parameters[:previous_response_id] = previous_response_id if previous_response_id.present?
    parameters[:input] = if image_url.present?
      [
        {
          "role" => "user",
          "content" => [
            {"type" => "input_text", "text" => prompt},
            {
              "type" => "input_image",
              "image_url" => image_url
            }
          ]
        }
      ]
    else
      prompt
    end

    Global.logger.info("[OpenaiClient][responses] request #{parameters} prompt:\n#{prompt}")
    response = Global.openai_client.responses.create(parameters: parameters)
    Global.logger.info("[OpenaiClient][responses] response #{response.inspect}")
    if !response["error"].present?
      result = response["output"].reverse.find { |c| c["type"] == "message" && c["role"] == "assistant" }&.dig("content", 0, "text") # This is where it would respond with images I think
      raise Error, "[OpenaiClient][responses] request #{parameters} prompt:\n#{prompt} gave a blank result: #{response}" if result.blank?
      [result, response["id"]]
    else
      error_message = begin
        response["error"]
      rescue
        nil
      end
      raise Error, ":bangbang: OpenAI returned error: #{error_message}"
    end
  end
end
