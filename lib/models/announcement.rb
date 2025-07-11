# frozen_string_literal: true

class Announcement
  include Comparable

  attr_reader :server, :channel, :message, :day, :month, :year, :weekdays, :source, :secret, :id, :guild_scheduled_event_id, :google_calendar_id

  def initialize(server:, channel:, message:, source:, day: nil, month: nil, year: nil, weekdays: nil, secret: false, id: nil, guild_scheduled_event_id: nil, google_calendar_id: nil)
    @server = server
    @channel = channel
    @message = message
    @day = day.presence&.to_i
    @month = month.presence&.to_i
    @year = year.presence&.to_i
    @weekdays = Array(weekdays).compact.map(&:downcase)
    @source = source.to_sym
    @secret = !!secret
    @id = id
    @guild_scheduled_event_id = guild_scheduled_event_id
    @google_calendar_id = google_calendar_id
  end

  class << self
    def all(server: nil)
      (ConfigAnnouncement.all(server: server) + DbAnnouncement.all(server: server)).sort
    end

    def build(*)
      raise NotImplementedError
    end

    def coerce_date(year:, month:, day:)
      year = year.to_i
      year += 2000 if year < 100
      month = coerce_month(month)
      day = day.to_i

      if year < 2023 || year > 2035 || !month || day < 1 || day > 31
        nil
      else
        [year, month, day]
      end
    end

    def coerce_month(str)
      return nil unless str.present? && str.to_s.present?
      str = str.to_s.strip.titlecase

      as_int = str.to_i
      return as_int if as_int > 0 && as_int <= 12

      Date::MONTHNAMES.index(str) || Date::ABBR_MONTHNAMES.index(str)
    end
  end

  def save
    raise NotImplementedError
  end

  def destroy
    raise NotImplementedError
  end

  def date
    Date.new(year, month, day) if day && month && year
  end

  def <=>(other)
    comparable_attributes <=> other.comparable_attributes
  end

  def comparable_attributes
    [
      server,
      channel,
      date || Date.new(1970, 1, 1),
      year || "",
      month || "",
      day || "",
      weekdays
    ]
  end

  def formatted_conditions
    if weekdays.any?
      "Every #{weekdays.map(&:titleize).to_sentence}"
    elsif year.blank?
      if month.blank?
        "The #{day}#{day.ordinal} of every month"
      else
        "#{Date::MONTHNAMES[month]} #{day}#{day.ordinal} every year"
      end
    elsif date
      date.strftime("%a %b %-d %Y")
    else
      ":question: #{conditions_hash.inspect}"
    end
  end

  def conditions_hash
    {
      day: day,
      month: month,
      year: year,
      weekdays: weekdays
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
    if (c = Pinger.find_channel(server: server, channel: channel))
      "<##{c.id}>"
    end
  end
end

class ConfigAnnouncement < Announcement
  def initialize(**args)
    super(**args.merge(source: :config))
  end

  class << self
    def all(server: nil)
      results = []

      Global.config.servers.each do |server_name, server_config|
        next if server.present? && server.to_s.delete("#") != server_name.to_s

        server_config.tasks&.daily_announcements&.each do |config|
          results << build(config, server: server_name)
        end
      end

      results.sort
    end

    def build(config, server:)
      new(
        server: server.presence.to_s.delete("#"),
        channel: config.channel.presence.to_s.delete("#"),
        message: config.message,
        day: config.day,
        month: config.month,
        year: config.year,
        weekdays: config.weekdays,
        secret: config.secret,
        guild_scheduled_event_id: config.guild_scheduled_event_id,
        source: :config
      )
    end
  end
end

class DbAnnouncement < Announcement
  def initialize(**args)
    super(**args.merge(source: :db))
  end

  class << self
    def all(server: nil)
      relation = Global.db[:announcements]
      relation = relation.where(server: server.to_s.delete("#")) if server.present?
      relation.map { |record| build(record) }.sort
    end

    def find(id)
      record = Global.db[:announcements].where(id: id).first
      build(record) if record
    end

    def build(record)
      new(
        server: record[:server].presence.to_s.delete("#"),
        channel: record[:channel].presence.to_s.delete("#"),
        message: record[:message].to_s,
        day: record[:day],
        month: record[:month],
        year: record[:year],
        weekdays: record[:weekdays],
        secret: record[:secret],
        guild_scheduled_event_id: record[:guild_scheduled_event_id],
        google_calendar_id: record[:google_calendar_id],
        id: record[:id]
      )
    end
  end

  def save
    id = Global.db[:announcements].insert(
      server: server,
      channel: channel,
      day: day,
      month: month,
      year: year,
      message: message,
      guild_scheduled_event_id: guild_scheduled_event_id,
      google_calendar_id: google_calendar_id
    )
    @id = id

    self if id
  end

  def destroy
    if id.blank?
      raise ArgumentError, "Cannot delete an announcement without an id"
    else
      count = Global.db[:announcements].where(id: id).delete
      !!(count == 1)
    end
  end

  def update(**args)
    Global.db[:announcements].where(id: id).update(args)
  end
end
