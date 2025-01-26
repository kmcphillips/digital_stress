# frozen_string_literal: true

class GifCommand < BaseCommand
  include AfterRecorderRedactAgainable

  def response
    if query.blank?
      "Quacking-search for something"
    else
      Dedup.new("Gif", event.server&.name, event.channel&.name).list(Gif.search_urls(query)) || "Quack-all found"
    end
  end
end
