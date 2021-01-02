# frozen_string_literal: true
class ImageCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for something"
    else
      Dedup.list(Azure.search_image_urls(query), namespace: ["Azure.image", event.server&.name, event.channel&.name, query.strip]) || "Quack-all found"
    end
  end
end
