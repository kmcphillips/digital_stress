# frozen_string_literal: true
class GifCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for something"
    else
      Dedup.list(Gif.search_urls(query), namespace: ["Gif", event.server&.name, event.channel&.name]) || "Quack-all found"
    end
  end
end
