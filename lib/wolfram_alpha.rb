# frozen_string_literal: true
module WolframAlpha
  extend self

  def query(search, location: nil)
    url = "http://api.wolframalpha.com/v2/query?input=#{ URI.encode(search.strip) }&appid=#{ ENV["WOLFRAM_APPID"] }"
    url = "#{ url }&location=#{ URI.encode(location.strip) }" if location.present?
    url = "#{ url }&format=plaintext" #,image

    response = HTTParty.get(url)

    if !response.success?
      Log.error("WolframAlpha#search returned HTTP #{ response.code }")
      Log.error(response.body)

      ":bangbang: Quack failure HTTP#{ response.code }"
    elsif response.dig("queryresult", "error") != "false"
      ":bangbang: queryresult.error was not false"
    elsif response.dig("queryresult", "success") == "true"
      extract_reply(response)
    else
      ":bangbang: queryresult.success was false"
    end
  end

  private

  def extract_reply(response)
    response["queryresult"]["pod"].map do |pod|
      subpods = pod["subpod"]
      subpods = [ subpods ] if subpods.is_a?(Hash)
      values = subpods.map { |subpod| subpod["plaintext"] }.compact

      "**#{ pod["title"]}** : #{ values.join(', ') }" unless values.blank?
    end.compact
  end
end
