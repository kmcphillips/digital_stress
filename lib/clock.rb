# frozen_string_literal: true
module Clockwork
  every(1.day, 'daily_announcements', at: '14:00', tz: 'UTC') do
    Global.logger.info("[clock] running DailyAnnouncements")
    DailyAnnouncements.new.run
  end
end
