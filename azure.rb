# frozen_string_literal: true
module Azure
  extend self

  def search_image_url(search)
    url = "https://api.cognitive.microsoft.com/bing/v7.0/images/search?q=#{ URI.encode(search.strip) }&count=10&offset=0&mkt=en-us&safeSearch=Off"
    response = HTTParty.get(url, { headers: { "Ocp-Apim-Subscription-Key" => ENV["AZURE_KEY"] } })

    if !response.success?
      Log.error("Azure#search_image_url returned HTTP #{ response.code }")
      Log.error(response.body)
      return ":bangbang: Quack failure HTTP#{ response.code }"
    end

    response["value"][0]["contentUrl"]
  end
end
