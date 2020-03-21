# frozen_string_literal: true
class GifCommand < BaseCommand
  def response
    search = params.join(" ")

    if search.blank?
      "Quacking-search for something"
    else
      Dedup.list(Gif.search_urls(search), namespace: ["Gif", event.server&.name, event.channel&.name, search.strip]) || "Quack-all found"
    end
  end
end
