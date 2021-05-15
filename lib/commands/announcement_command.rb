# frozen_string_literal: true
class AnnouncementCommand < BaseSubcommand
  def subcommands
    {
      list: "List all upcoming announcements on this server.",
    }.freeze
  end

  private

  def list
    server_name = server
    server_name = params[1] if pm? && params[1].present?

    announcements = Announcement.find(server: server_name).reject(&:expired?)

    if announcements.any?
      announcements.map { |a| format_announcement(a) }.join("\n")
    else
      ":outbox_tray: No upcoming announcements."
    end
  end

  def format_announcement(announcement)
    "* `#{ announcement.formatted_conditions } in #{ announcement.channel }: #{ announcement.message }`"
  end
end
