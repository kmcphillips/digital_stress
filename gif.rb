# frozen_string_literal: true
module Gif
  extend self

  def search_url(search)
    url = "https://api.giphy.com/v1/gifs/search?api_key=#{ ENV["GIPHY_KEY"] }&q=#{ URI.encode(search.strip) }&limit=3&offset=0&rating=R&lang=en"
    response = HTTParty.get(url)

    if !response.success?
      Log.error("Gif#search_url returned HTTP #{ response.code }")
      Log.error(response.body)
      return ":bangbang: Quack failure HTTP#{ response.code }"
    end

    response["data"][0]["images"]["downsized_large"]["url"]
  end
end
