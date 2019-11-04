# frozen_string_literal: true
module Commands
  extend self

  ALL = {
    help: "Shows this message.",
    ping: "Hello, is it me you're looking for?",
    steam: "Paste a link to the steam game matching the search."
  }.freeze

  def handles?(command)
    ALL.keys.map{ |c| c.to_s.downcase }.include?(command)
  end

  def help(params:, event:)
    lines = ALL.map do |command, help|
      "**#{ command }**: #{ help }" if help
    end
    event.respond(lines.reject(&:blank?).join("\n"))
  end

  def ping(params:, event:)
    event.respond(":white_check_mark: Quack")
  end

  def steam(params:, event:)
    if params.blank?
      event.respond("Quacking-search for something")
    else
      url = Steam.search_game_url(params)
      event.respond(url || "Quack-all found")
    end
  end
end
