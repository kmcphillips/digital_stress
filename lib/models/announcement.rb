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

  def date
    Date.new(year, month, day) if day && month && year
  end

  def formatted_conditions
    if weekdays.any?
      "Every #{ weekdays.map(&:titleize).to_sentence }"
    else
      if year.blank?
        if month.blank?
          "The #{ day }#{ day.ordinal } of every month"
        else
          "#{ Date::MONTHNAMES[month] } #{ day }#{ day.ordinal } every year"
        end
      elsif date
        date.inspect
      else
        ":question: #{ conditions_hash.inspect }"
      end
    end
  end

  def conditions_hash
    {
      day: day,
      month: month,
      year: year,
      weekdays: weekdays,
    }
  end

  def triggers_on_day?(trigger_date)
    if weekdays.any?
      weekdays.include?(Date::DAYNAMES[trigger_date.wday].downcase)
    elsif date
      date == trigger_date
    else
      return false if year.present? && year != trigger_date.year
      return false if month.present? && month != trigger_date.month
      trigger_date.day == day
    end
  end

  def expired?
    # TODO: this only looks at y/m/d full combinations
    !!(date && date < Date.today)
  end

  def rendered_message
    template = ERB.new(message)
    template.result(binding) # TODO: expose a more useful binding here rather than counting on globals
  end

  def channel_link
    if c = Pinger.find_channel(server: server, channel: channel)
      "<##{ c.id }>"
    end
  end
end
