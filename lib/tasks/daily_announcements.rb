# frozen_string_literal: true
class DailyAnnouncements < TaskBase
  def run
    results = []

    Announcement.all.each do |announcement|
      results << process_daily_announcement(announcement)
    end

    results.select(&:present?).count
  end

  private

  def process_daily_announcement(announcement)
    if announcement.triggers_on?(day: Date.today)
      channel = Pinger.find_channel(server: announcement.server, channel: announcement.channel)
      channel.send_message(announcement.rendered_message)

      true
    end
  end
end
