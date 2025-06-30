# frozen_string_literal: true

class ImageCommand < BaseCommand
  include AfterRecorderRedactAgainable

  def response
    if query.blank?
      "Quacking-search for something"
    else
      Dedup.new("SerpApi.image", event.server&.name, event.channel&.name, query.strip).list(SerpApi.google_image_search(query)) || "Quack-all found"
    end
  end
end
