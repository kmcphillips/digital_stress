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
      Log.error(response)
      ":bangbang: queryresult.error was not false"
    elsif response.dig("queryresult", "success") == "true"
      extract_success_reply(response)
    else
      Log.error(response)

      if response["queryresult"]["didyoumeans"]
        extract_didyoumean_reply(response)
      else
        ":bangbang: queryresult.success was false and had no guesses"
      end
    end
  end

  private

  def extract_success_reply(response)
    response["queryresult"]["pod"].map do |pod|
      if pod["id"] == "Input"
        "#{ pod["subpod"]["plaintext"] }\n"
      else
        subpods = pod["subpod"]
        subpods = [ subpods ] if subpods.is_a?(Hash)
        values = subpods.map { |subpod| subpod["plaintext"] }.compact

        "**#{ pod["title"]}** : #{ values.join(', ') }" unless values.blank?
      end
    end.compact
  end

  def extract_didyoumean_reply(response)
    result = [":thinking: Did you mean?"]

    response["queryresult"]["didyoumeans"]["didyoumean"].map do |dym|
      result << "    #{ dym["__content__"] } (#{ dym["score"].to_f.round(1) * 100 }%)"
    end

    result
  end
end
