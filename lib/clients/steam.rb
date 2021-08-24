# frozen_string_literal: true
module Steam
  extend self

  USERAGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0) Gecko/20100101 Firefox/70.0"

  def search_game_url(search)
    url = "https://store.steampowered.com/search/?term=#{ URI.encode_www_form_component(search.strip) }"
    response = HTTParty.get(url, { headers: { "User-Agent" => USERAGENT } })
    begin
      document = Nokogiri::HTML(response.body)
    rescue HTTParty::Error => e
      Global.logger.error("Steam#search_game_url failed for '#{ search }'")
      Global.logger.error(e.message)
      Global.logger.error(e)
      return ":bangbang: Quack error #{ e.class } #{ e.message }"
    end

    if !response.success?
      Global.logger.error("Steam#search_game_url returned HTTP #{ response.code }")
      Global.logger.error(response.body)
      return ":bangbang: Quack failure HTTP#{ response.code }"
    end

    if document.css("a.search_result_row").any?
      document.css("a.search_result_row").first.attribute("href").value.gsub(/\/\?.+/, "")
    else
      nil
    end
  end
end
