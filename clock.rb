# frozen_string_literal: true
require "clockwork"

require_relative "base"

module Clockwork
  # configure do |config|
  #   config[:logger] = Global.logger
  # end

  error_handler do |error|
    Global.logger.error("Clockwork error: #{ error }")
    Global.logger.error(error)
  end

  every(1.day, 'test.morning', at: '12:00', tz: 'UTC') do
    Global.logger.info("Nice... called this from clock.rb in the morning")
  end

  every(1.minute, 'test.minutely') do
    Global.logger.info("Tick... called this from clock.rb every minute")
  end
end

