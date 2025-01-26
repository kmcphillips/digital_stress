# frozen_string_literal: true

class WolframAlphaCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for something"
    else
      WolframAlpha.query(query, location: user.location)
    end
  end
end
