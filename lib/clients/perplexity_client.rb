# frozen_string_literal: true

module PerplexityClient
  extend self

  class Error < StandardError; end

  def default_model
    "sonar-pro"
  end

  def models
    client.models
  end

  def default_guidance
    "Be very brief and concise. The maximum character limit is 2000 characters so stay under that. Response will be used in a Discord chat so aim for quick responses. Use a casual friendly tone, like friends having a conversation. Sparsely include a \"Quack!\" at the end of messages or between sentences."
  end

  def chat(prompt, params = {})
    built_params = {
      model: params[:model].presence || default_model,
      messages: [
        {
          role: "system",
          content: params[:guidance].presence || default_guidance
        },
        {
          role: "user",
          content: prompt
        }
      ]
    }

    Global.logger.info("[PerplexityClient][chat] parameters #{built_params.inspect}")
    response = client.client.chat(parameters: built_params)
    # TODO: check response for errors and raise Error
    Global.logger.info("[PerplexityClient][chat] response #{response.inspect}")
    response["choices"].map { |c| c.dig("message", "content") }
  end

  private

  def client
    @client ||= Perplexity::API.new(api_key: Global.config.perplexity.key)
  end
end
