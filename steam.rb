# frozen_string_literal: true
module Steam
  extend self

  USERAGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0) Gecko/20100101 Firefox/70.0"

  def search_game_url(search)
    url = "https://store.steampowered.com/search/?term=#{ URI.encode(search.strip) }"
    response = HTTParty.get(url, { headers: { "User-Agent" => USERAGENT } })
    document = Nokogiri::HTML(response.body)

    if document.css("a.search_result_row").any?
      document.css("a.search_result_row").first.attribute("href").value.gsub(/\/\?.+/, "")
    else
      nil
    end
  end
end
