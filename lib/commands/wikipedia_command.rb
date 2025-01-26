# frozen_string_literal: true

class WikipediaCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for something"
    else
      WikipediaClient.search_url(query) || ":mag: Quack, could not find that page"
    end
  end
end
