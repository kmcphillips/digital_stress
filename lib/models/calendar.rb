# frozen_string_literal: true

class Calendar
  def initialize(announcements, hostname: nil, url: nil, name: nil, organizer_email: nil)
    @announcements = announcements
    @hostname = hostname
    @url = url
    @name = name
    @ics = nil
    @organizer_email = organizer_email
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

      organizer = Icalendar::Values::CalAddress.new("mailto:#{@organizer_email}") if @organizer_email.present?

      @announcements.each do |announcement|
        summary = announcement.calendar_summary.presence || announcement.message
        description = announcement.calendar_description.presence || announcement.message
        url = announcement.url.presence
        sequence = announcement.timestamp
        sequence += 1 if announcement.cancelled?
        start_time = Time.at(announcement.calendar_start_time).to_datetime # TODO: Use the actual announcement time if present.
        end_time = Time.at(announcement.calendar_end_time).to_datetime # TODO: Use the actual announcement time if present.

        cal.event do |event|
          event.sequence = sequence
          event.summary = summary
          event.description = description
          event.url = url if url
          event.organizer = organizer if organizer
          event.dtstart = Icalendar::Values::DateTime.new(start_time, "tzid" => tzid)
          event.dtend = Icalendar::Values::DateTime.new(end_time, "tzid" => tzid)
          event.uid = [announcement.unique_id, @hostname].reject(&:blank?).join("@")
          event.alarm do |a|
            a.trigger = "-PT30M"
            a.summary = "#{summary} in half an hour"
            a.description = "#{summary} in half an hour"
          end
          event.status = "CANCELLED" if announcement.cancelled?
        end
      end

      cal.publish
      @ics = cal.to_ical
    end

    @ics
  end
end
