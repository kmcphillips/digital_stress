# frozen_string_literal: true

module Gif
  extend self

  def search_urls(search)
    url = "https://api.giphy.com/v1/gifs/search?api_key=#{key}&q=#{URI.encode_www_form_component(search.strip)}&limit=20&offset=0&rating=R&lang=en"
    response = HTTParty.get(url)

    if !response.success?
      Global.logger.error("Gif#search_url returned HTTP #{response.code}")
      Global.logger.error(response.body)
      return ":bangbang: Quack failure HTTP#{response.code}"
    end

    (response["data"] || []).map { |r| r.dig("images", "downsized_large", "url").presence }.compact
  end

  private

  def key
    Global.config.giphy.key
  end
end
