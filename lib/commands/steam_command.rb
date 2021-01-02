# frozen_string_literal: true
class SteamCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for a game"
    else
      Steam.search_game_url(query) || "Quack-all found games found"
    end
  end
end
