# frozen_string_literal: true

class GoogleImageSearchResponder < BaseResponder
  def respond
    if (match_data = text.match(/(https:\/\/images\.app\.goo\.gl\/[a-zA-Z0-9]+)/))
      url = match_data[0]
      response = HTTParty.head(url, follow_redirects: false)

      if response.code == 302
        if response.headers["location"].present?
          redirect_url = response.headers["location"]
          image_url = Rack::Utils.parse_nested_query(URI.parse(redirect_url).query)["imgurl"]

          if image_url.present?
            event.respond([sass, image_url].reject(&:blank?).join("\n"))
          else
            Global.logger.warn("[GoogleImageSearchResponder] for #{url} #{redirect_url} did does not have an imgurl part")
            event.message.react("❔")
          end
        else
          Global.logger.warn("[GoogleImageSearchResponder] for #{url} does not have a location header")
          event.message.react("❔")
        end
      else
        Global.logger.warn("[GoogleImageSearchResponder] for #{url} did not return a 302")
        event.message.react("❔")
      end
    end
  end

  private

  def sass
    # "Why is this always so hard #{ mention }?
    Quacker.quack
  end
end
