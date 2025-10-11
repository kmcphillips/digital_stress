# frozen_string_literal: true

class DndCommand < BaseSubcommand
  def subcommands
    {
      spell: "Search for a spell by name in the 2024 ruleset.",
      dates: "Show the upcoming announcement dates.",
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
      start_hour, start_minute, start_second = [20, 0, 0]
      end_hour, end_minute, end_second = [23, 45, 0]
      discord_url = "https://discord.com/channels/824835225263669258/824835225263669263"

      if !year || !month || !day
        "Quack! Could not parse date. Usage: `#{add_usage}`"
      else
        announcement = DbAnnouncement.new(
          server: server,
          channel: channel,
          message: add_message,
          day: day,
          month: month,
          year: year,
          url: discord_url,
          calendar_start_time: DateTime.new(year, month, day, start_hour, start_minute, start_second).to_i,
          calendar_end_time: DateTime.new(year, month, day, end_hour, end_minute, end_second).to_i,
          calendar_summary: "D&D",
          calendar_description: "D&D tonight, sharp time."
        )
        result = announcement.save

        if result
          start_time = Time.new(year, month, day, start_hour, start_minute, start_second, ActiveSupport::TimeZone["America/Toronto"].tzinfo.utc_offset)
          end_time = Time.new(year, month, day, end_hour, end_minute, end_second, ActiveSupport::TimeZone["America/Toronto"].tzinfo.utc_offset)

          response_message = "Quack! #{Pinger.find_emoji("d20", server: server) || ":game_die:"} D&D added on **#{result.formatted_conditions}**"

          begin
            guild_scheduled_event_result = DiscordRestApi.create_guild_scheduled_event(
              name: "D&D",
              description: "D&D tonight! Sharp time.",
              location: discord_url,
              start_time: start_time.iso8601,
              end_time: end_time.iso8601,
              image: Global.root.join("data", "dnd_event_banner.png"),
              server: server
            )

            announcement.update(guild_scheduled_event_id: guild_scheduled_event_result["id"])
          rescue => e
            response_message += " Failed to create server event! #{e.inspect}"
          end

          begin
            google_emails = if server == "mandatemandate"
              [User.patrick.email, User.dave.email, User.eliot.email, User.arturo.email]
            else
              []
            end

            google_calendar_result = GoogleCalendarClient.create_event(
              title: "D&D",
              start_time: start_time,
              end_time: end_time,
              location: discord_url,
              description: "D&D tonight, sharp time.",
              email_invites: google_emails
            )

            announcement.update(google_calendar_id: google_calendar_result.id)
          rescue => e
            response_message += " Failed to create calendar event! #{e.inspect}"
          end

          response_message
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
    result = Dnd2024Data.find_spell(params.join(" "))

    if result
      result.to_discord_s
    else
      "Quack! Nothing found??"
    end
  end
end
