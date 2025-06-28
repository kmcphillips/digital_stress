# frozen_string_literal: true

module Clockwork
  every(1.day, "daily_announcements", at: "14:00", tz: "UTC") do
    Global.logger.info("[clock] running DailyAnnouncements")
    DailyAnnouncements.new.run
  end

  every(1.day, "google_calendar_keep_alive", at: "12:00", tz: "UTC") do
    Global.logger.info("[clock] running Google Calendar keep-alive")
    GoogleCalendarClient.keep_alive
  end
end
