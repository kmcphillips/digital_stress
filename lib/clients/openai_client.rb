# frozen_string_literal: true

module OpenaiClient
  extend self

  class Error < StandardError; end

  def default_model
    "gpt-5"
  end

  def default_image_model
    # This appears to now always be base 64 encoded data so no URLs returned
    "gpt-image-1" # "gpt-image-1-mini"
  end

  def models
    Global.openai_client.models.list["data"].map { |m| m["id"] }
  end

  def chat(prompt, openai_params = {})
    parameters = openai_params.symbolize_keys
    image_url = parameters.delete(:image_url)
    Global.logger.info("[OpenaiClient][chat] request #{parameters} prompt:\n#{prompt} image_url:\n#{image_url}")
    raise Error, "[OpenaiClient][chat] passed in `engine` param, use `model` instead" if parameters.key?(:engine)
    parameters[:model] ||= OpenaiClient.default_model
    parameters[:messages] = if image_url.present?
      [{role: "user", content: [
        {type: "text", text: prompt},
        {type: "image_url", image_url: {url: image_url}}
      ]}]
    else
      [{role: "user", content: prompt}]
    end
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
  rescue Faraday::Error => e
    Global.logger.error("[OpenaiClient][chat] Faraday error: #{e.message}")
    Global.logger.error("[OpenaiClient][chat] response #{e.response_body}") if e.respond_to?(:response_body)
    raise
  end

  # As of gpt-image-1 this appears to only return base 64 so this won't return URls anymore and probably isn't needed, just use `image_file`.
  def image(prompt, openai_params = {})
    parameters = openai_params.symbolize_keys
    Global.logger.info("[OpenaiClient][image] request #{parameters} prompt:\n#{prompt}")
    parameters[:model] ||= OpenaiClient.default_image_model
    parameters[:prompt] = prompt
    parameters[:size] ||= "1536x1024"
    response = Global.openai_client.images.generate(parameters: parameters)
    Global.logger.info("[OpenaiClient][image] response #{response.inspect}")
    if !response.key?("error")
      if response["output_format"] == "png"
        raise Error, "[OpenaiClient][image] expected data to have length of 1 but got #{response["data"].count}" if response["data"].count != 1
        raise Error, "[OpenaiClient][image] data does not include a b64_json key" unless response["data"][0].keys.include?("b64_json")
        result = [response["data"][0]["b64_json"]]
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
  rescue Faraday::Error => e
    Global.logger.error("[OpenaiClient][image] Faraday error: #{e.message}")
    Global.logger.error("[OpenaiClient][image] response #{e.response_body}") if e.respond_to?(:response_body)
    raise
  end

  def image_file(prompt, openai_params = {})
    parameters = openai_params.symbolize_keys
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
  rescue Faraday::Error => e
    Global.logger.error("[OpenaiClient][responses] Faraday error: #{e.message}")
    Global.logger.error("[OpenaiClient][responses] response #{e.response_body}") if e.respond_to?(:response_body)
    raise
  end
end
