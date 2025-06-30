# frozen_string_literal: true

module SerpApi
  extend self

  def google_image_search(search)
    search = GoogleSearch.new(q: search, tbm: "isch", serp_api_key: Global.config.serp_api.key)
    search.get_hash[:images_results].map { |r| r[:original] }
  end
end
