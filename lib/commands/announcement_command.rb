# frozen_string_literal: true
class AnnouncementCommand < BaseSubcommand
  def subcommands
    {
      list: "List all upcoming announcements on this server.",
      add: "Add a new announcement. Usage: `#{ usage }`",
    }.freeze
  end

  private

  def list
    server_name = server
    server_name = params[1] if pm? && params[1].present?

    announcements = Announcement.all(server: server_name).reject(&:expired?)
    announcements = announcements.reject(&:secret) unless pm?

    if announcements.any?
      announcements.map { |a| "* #{ format_announcement(a) }" }.join("\n")
    else
      ":outbox_tray: No upcoming announcements."
    end
  end

  def add
    if subcommand_params.length < 4
      "Quack! Usage: `#{ usage }`"
    else
      year, month, day = Announcement.coerce_date(year: subcommand_params[0], month: subcommand_params[1], day: subcommand_params[2])
      message = subcommand_params[3..-1].join(" ")

      if !year || !month || !day || message.blank?
        "Quack! Could not parse date. Usage: `#{ usage }`"
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
          "Quack! Announcement added.\n#{ format_announcement(result) }"
        else
          "Quack! Could not add announcement!"
        end
      end
    end
  end

  def usage
    "duck announcement add YEAR MONTH DAY Then the message"
  end

  def format_announcement(announcement)
    "**#{ announcement.formatted_conditions }** in **#{ announcement.channel }**#{ announcement.secret ? " (secret)" : "" }: `#{ announcement.message }`"
  end
end
