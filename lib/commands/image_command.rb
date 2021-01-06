# frozen_string_literal: true
class ImageCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for something"
    else
      Dedup.new("Azure.image", event.server&.name, event.channel&.name, query.strip).list(Azure.search_image_urls(query)) || "Quack-all found"
    end
  end
end
