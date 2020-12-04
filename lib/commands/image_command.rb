# frozen_string_literal: true
class ImageCommand < BaseCommand
  def response
    search = params.join(" ")

    if search.blank?
      "Quacking-search for something"
    else
      Dedup.list(Azure.search_image_urls(search), namespace: ["Azure.image", event.server&.name, event.channel&.name, search.strip]) || "Quack-all found"
    end
  end
end
