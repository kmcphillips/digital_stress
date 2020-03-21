# frozen_string_literal: true
class SteamCommand < BaseCommand
  def response
    search = params.join(" ")

    if search.blank?
      "Quacking-search for a game"
    else
      Steam.search_game_url(search) || "Quack-all found games found"
    end
  end
end
