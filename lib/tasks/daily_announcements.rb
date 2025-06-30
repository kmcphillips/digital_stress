# frozen_string_literal: true

class DailyAnnouncements < TaskBase
  def run
    announcements = Announcement.all.select { |a| a.triggers_on_day?(Date.today) }
    Global.logger.info("[DailyAnnouncements] Found #{announcements.count} #{announcements.count == 1 ? "announcement" : "announcements"} to send")

    announcements.each do |announcement|
      channel = Pinger.find_channel(server: announcement.server, channel: announcement.channel)

      if channel
        Global.logger.info("[DailyAnnouncements] Sending announcement to #{announcement.channel} on #{announcement.server}")
        channel.send_message(announcement.rendered_message)
      else
        Global.logger.error("[DailyAnnouncements] Failed to find channel #{announcement.channel} on #{announcement.server}")
      end
    end

    announcements.count
  end
end
