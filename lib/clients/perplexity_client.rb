# frozen_string_literal: true

module PerplexityClient
  extend self

  class Error < StandardError; end

  def default_model
    "sonar-pro"
  end

  def default_guidance
    "Be very brief and concise. The maximum character limit is 2000 characters so stay under that. Response will be used in a Discord chat so aim for quick responses. Use a casual friendly tone, like friends having a conversation. Sparsely include a \"Quack!\" at the end of messages or between sentences."
  end

  def chat(prompt, params = {})
    messages = [
      {
        role: "system",
        content: params[:guidance].presence || default_guidance
      },
      {
        role: "user",
        content: prompt
      }
    ]

    Global.logger.info("[PerplexityClient][chat] parameters #{messages.inspect}")
    response = client.chat(messages)
    # TODO: check response for errors and raise Error
    Global.logger.info("[PerplexityClient][chat] response #{response.inspect}")
    response_text = response.dig("choices", 0, "message", "content").presence || response.dig("error", "message") || "Quack! Error?? #{response.inspect}"
    [response_text, response.dig("citations")]
  end

  private

  def client
    @client ||= PerplexityApi.new(api_key: Global.config.perplexity.key, model: default_model)
  end
end
