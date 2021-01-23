# frozen_string_literal: true
module WikipediaClient
  extend self

  def search_url(search)
    page = Wikipedia.find(search.strip)

    if page.raw_data.dig("query", "pages").values.first.key?("missing")
      nil
    else
      page.fullurl
    end
  end
end
