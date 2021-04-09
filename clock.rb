# frozen_string_literal: true
require "clockwork"

require_relative "base"

Global.bot = Discordrb::Bot.new(token: Global.config.discord.token)
Global.bot.run(true)

module Clockwork
  configure do |config|
    config[:logger] = Global.logger
  end

  error_handler do |error|
    Global.logger.error("Clockwork error: #{ error }")
    Global.logger.error(error)
  end

  every(1.day, 'daily_announcements', at: '12:00', tz: 'UTC') do
    Global.logger.info("[clock] running DailyAnnouncements")
    DailyAnnouncements.new.run
  end
end
