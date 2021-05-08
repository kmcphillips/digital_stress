# frozen_string_literal: true
class Announcement
  attr_reader :server, :channel, :message, :day, :month, :year, :weekdays, :source

  def initialize(server:, channel:, message:, day: nil, month: nil, year: nil, weekdays: nil, source:)
    @server = server
    @channel = channel
    @message = message
    @day = day.presence&.to_i
    @month = month.presence&.to_i
    @year = year.presence&.to_i
    @weekdays = Array(weekdays).compact.map(&:downcase)
    @source = source.to_sym
  end

  class << self
    def find(server:)
      results = []

      (Global.config.servers[server]&.tasks&.daily_announcements || []).each do |config|
        results << from_config(config, server: server)
      end

      results
    end

    def all
      results = []

      Global.config.servers.each do |server_name, server_config|
        if server_config.tasks&.daily_announcements
          server_config.tasks.daily_announcements.each do |config|
            results << from_config(config, server: server_name)
          end
        end
      end

      results
    end

    def from_config(config, server:)
      self.new(
        server: server.presence.to_s.gsub("#", ""),
        channel: config.channel.presence.to_s.gsub("#", ""),
        message: config.message,
        day: config.day,
        month: config.month,
        year: config.year,
        weekdays: config.weekdays,
        source: :config
      )
    end
  end

  def triggers_on?(day: nil)
    if day
      if weekdays.any?
        weekdays.include?(Date::DAYNAMES[day.wday].downcase)
      else
        return false if year.present? && year != day.year
        return false if month.present? && month != day.month
        day.day == day
      end
    else # TODO: elsif time: etc
      false
    end
  end
end
