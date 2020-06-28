# frozen_string_literal: true
class WolframAlphaCommand < BaseCommand
  def response
    search = params.join(" ")

    if search.blank?
      "Quacking-search for something"
    else
      WolframAlpha.query(search, location: user.location)
    end
  end
end
