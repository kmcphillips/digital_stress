# frozen_string_literal: true

class DndCommand < BaseSubcommand
  def subcommands
    {
      dates: "Show the upcoming announcement dates.",
      spell: "Search for a spell by name.",
      add: "Add a D&D announcement date. Usage: `#{add_usage}`"
    }.freeze
  end

  def dates
    AnnouncementCommand.new(event: event, bot: bot, params: ["list"]).send(:list)
  end

  def add
    if subcommand_params.length != 3
      "Quack! Usage: `#{add_usage}`"
    else
      year, month, day = Announcement.coerce_date(year: subcommand_params[0], month: subcommand_params[1], day: subcommand_params[2])

      if !year || !month || !day
        "Quack! Could not parse date. Usage: `#{add_usage}`"
      else
        announcement = DbAnnouncement.new(
          server: server,
          channel: channel,
          message: add_message,
          day: day,
          month: month,
          year: year
        )
        result = announcement.save

        if result
          begin
            guild_scheduled_event_result = DiscordRestApi.create_guild_scheduled_event(
              name: "D&D",
              description: "D&D tonight! Sharp time.",
              location: "https://discord.com/channels/824835225263669258/824835225263669263",
              start_time: Time.new(year, month, day, 20, 0, 0, ActiveSupport::TimeZone["America/Toronto"].tzinfo.utc_offset).iso8601,
              end_time: Time.new(year, month, day, 23, 45, 0, ActiveSupport::TimeZone["America/Toronto"].tzinfo.utc_offset).iso8601,
              image: Global.root.join("data", "dnd_event_banner.png"),
              server: server
            )

            announcement.update(guild_scheduled_event_id: guild_scheduled_event_result["id"])

            "Quack! #{Pinger.find_emoji("d20", server: server) || ":game_die:"} D&D added on **#{result.formatted_conditions}**"
          rescue => e
            "Quack! #{Pinger.find_emoji("d20", server: server) || ":game_die:"} D&D added on **#{result.formatted_conditions}** but failed to create server event! #{e.inspect}"
          end
        else
          "Quack! Rolled a nat-1 on that and could not add the date."
        end
      end
    end
  end

  def add_usage
    "duck dnd add YEAR MONTH DAY"
  end

  def add_message
    "@everyone :man_mage: D&D tonight! Sharp time 8PM Eastern."
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
