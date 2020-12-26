# frozen_string_literal: true
module Azure
  extend self

  def search_image_urls(search)
    url = "https://api.cognitive.microsoft.com/bing/v7.0/images/search?q=#{ URI.encode(search.strip) }&count=20&offset=0&mkt=en-us&safeSearch=Off"
    response = HTTParty.get(url, { headers: { "Ocp-Apim-Subscription-Key" => key } })

    if !response.success?
      Log.error("Azure#search_image_urls returned HTTP #{ response.code }")
      Log.error(response.body)
      return ":bangbang: Quack failure HTTP#{ response.code }"
    end

    (response["value"] || []).map{ |r| r["contentUrl"].presence }.compact
  end

  private

  def key
    Configuration.azure.key
  end
end
