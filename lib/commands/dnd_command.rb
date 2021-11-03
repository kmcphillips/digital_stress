# frozen_string_literal: true
class DndCommand < BaseSubcommand
  CHANNELS = [
    "mandatemandate#general",
    "duck-bot-test#testing",
  ].freeze

  def channels
    CHANNELS
  end

  def subcommands
    {
      dates: "Show the upcoming announcement dates.",
      spell: "Search for a spell by name."
    }.freeze
  end

  def dates
    AnnouncementCommand.new(event: event, bot: bot, params: ["list"]).send(:list)
  end

  def spell
    result = Dnd5eData.find_spell(params.join(" "))

    if result
      result.to_discord_s
    else
      "Quack! Nothing found??"
    end
  end
end
