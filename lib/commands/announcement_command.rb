# frozen_string_literal: true
class AnnouncementCommand < BaseSubcommand
  def subcommands
    {
      list: "List all upcoming announcements on this server.",
    }.freeze
  end

  private

  def list
    announcements = Announcement.find(server: server).reject(&:expired?)

    if announcements.any?
      announcements.map { |a| format_announcement(a) }.join("\n")
    else
      ":outbox_tray: No upcoming announcements."
    end
  end

  def format_announcement(announcement)
    "* On **#{ announcement.formatted_conditions }** in ##{ announcement.channel }: #{ announcement.message }"
  end
end
