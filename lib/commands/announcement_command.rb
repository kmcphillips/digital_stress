# frozen_string_literal: true

class AnnouncementCommand < BaseSubcommand
  def subcommands
    {
      list: "List all upcoming announcements on this server.",
      add: "Add a new announcement. Usage: `#{add_usage}`",
      delete: "Delete an announcment. Usage: `#{delete_usage}`"
    }.freeze
  end

  private

  def list
    server_name = server
    server_name = params[1] if pm? && params[1].present?

    announcements = Announcement.all(server: server_name).reject(&:expired?)
    announcements = announcements.reject(&:secret) unless pm?

    if announcements.any?
      announcements.map { |a| "* #{format_announcement(a)}" }.join("\n")
    else
      ":outbox_tray: No upcoming announcements."
    end
  end

  def add
    if subcommand_params.length < 4
      "Quack! Usage: `#{add_usage}`"
    else
      year, month, day = Announcement.coerce_date(year: subcommand_params[0], month: subcommand_params[1], day: subcommand_params[2])
      message = subcommand_params[3..].join(" ")

      if !year || !month || !day || message.blank?
        "Quack! Could not parse date. Usage: `#{add_usage}`"
      else
        result = DbAnnouncement.new(
          server: server,
          channel: channel,
          message: message,
          day: day,
          month: month,
          year: year
        ).save

        if result
          "Quack! Announcement added.\n#{format_announcement(result)}"
        else
          "Quack! Could not add announcement!"
        end
      end
    end
  end

  def delete
    if subcommand_params.length == 0
      announcements = DbAnnouncement.all(server: server).reject(&:expired?)
      announcements = announcements.reject(&:secret) unless pm?

      if announcements.any?
        announcements.map { |a| "**(#{a.id})** on **#{a.formatted_conditions}** in **#{a.channel}**" }.join("\n")
      else
        ":outbox_tray: No upcoming announcements."
      end
    elsif subcommand_params.length == 1
      announcement = DbAnnouncement.find(subcommand_params[0])

      if announcement
        if announcement.guild_scheduled_event_id
          begin
            DiscordRestApi.delete_guild_scheduled_event(announcement.guild_scheduled_event_id, server: server)
          rescue
            Global.logger.error("[AnnouncementCommand] Failed to delete guild scheduled event #{announcement.guild_scheduled_event_id} for announcement #{announcement.id} on server #{server}")
          end
        end

        if announcement.google_calendar_id
          begin
            GoogleCalendarClient.delete_event(announcement.google_calendar_id)
          rescue
            Global.logger.error("[AnnouncementCommand] Failed to delete google calendar event #{announcement.google_calendar_id} for announcement #{announcement.id} on server #{server}")
          end
        end

        if announcement.destroy
          "Quack! Announcement deleted.\n#{format_announcement(announcement)}"
        else
          "Quack! Could not delete announcement!"
        end
      else
        "Quack! Could not find announcement by id `#{subcommand_params[0]}`."
      end
    else
      "Quack! Usage: `#{delete_usage}`"
    end
  end

  def add_usage
    "duck announcement add YEAR MONTH DAY Then the message"
  end

  def delete_usage
    "duck announcement delete ID"
  end

  def format_announcement(announcement)
    "**#{announcement.formatted_conditions}** in **#{announcement.channel}**#{announcement.secret ? " (secret)" : ""}: `#{announcement.message}`"
  end
end
