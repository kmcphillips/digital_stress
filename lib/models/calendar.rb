# frozen_string_literal: true

class Calendar
  def initialize(announcements, hostname: nil, url: nil, name: nil)
    @announcements = announcements
    @hostname = hostname
    @url = url
    @name = name
    @ics = nil
  end

  def to_ics
    unless @ics
      cal = Icalendar::Calendar.new
      cal.url = @url if @url.present?

      cal.description = @name
      cal.prodid = "-//#{@name}//EN"
      cal.x_wr_calname = @name
      cal.x_wr_caldesc = @name

      tzid = "America/Toronto"
      tz = TZInfo::Timezone.get(tzid)
      timezone = tz.ical_timezone(Time.now)
      cal.add_timezone(timezone)

      @announcements.each do |announcement|
        # TODO: This hacks aound some weak points in the datamodel. I should probably rewrite all the announcment/dnd code.
        summary = announcement.extended_attributes[:summary].presence || announcement.message
        description = announcement.extended_attributes[:description].presence || announcement.message
        url = announcement.extended_attributes[:discord_url].presence
        start_time = announcement.extended_attributes[:start_time] # TODO: Use the actual announcement time if present.
        end_time = announcement.extended_attributes[:end_time] # TODO: Use the actual announcement time if present.

        cal.event do |event|
          event.summary = summary
          event.description = description
          event.url = url if url
          event.dtstart = Icalendar::Values::DateTime.new(start_time, "tzid" => tzid)
          event.dtend = Icalendar::Values::DateTime.new(end_time, "tzid" => tzid)
          event.uid = [announcement.unique_id, @hostname].reject(&:blank?).join("@")
          event.alarm do |a|
            a.trigger = "-PT30M"
            a.summary = "#{summary} in half an hour"
            a.description = "#{summary} in half an hour"
          end
        end
      end

      cal.publish
      @ics = cal.to_ical
    end

    @ics
  end
end
