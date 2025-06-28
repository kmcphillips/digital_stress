# frozen_string_literal: true

module GoogleCalendarClient
  extend self

  def keep_alive
    service.list_calendar_lists(max_results: 10)
    Global.logger.info("[GoogleCalendarClient] Keep-alive successful")
    true
  rescue => e
    Global.logger.error("[GoogleCalendarClient] Keep-alive failed: #{e.message}")
    raise
  end

  def create_event(title:, start_time:, end_time:, location: nil, description: nil, email_invites: [], reminder_minutes: nil)
    reminders = if reminder_minutes
      Google::Apis::CalendarV3::Event::Reminders.new(
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(reminder_method: "popup", minutes: reminder_minutes.to_i)
        ]
      )
    else
      nil
    end

    event = Google::Apis::CalendarV3::Event.new(
      summary: title,
      location: location,
      description: description,
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time.iso8601, time_zone: "America/Toronto"),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time.iso8601, time_zone: "America/Toronto"),
      attendees: email_invites.map { |email| Google::Apis::CalendarV3::EventAttendee.new(email: email) },
      reminders: reminders
    )

    result = service.insert_event("primary", event, send_notifications: true)
    raise "Failed to create event. Got status '#{result.status}' #{result.inspect}" if result.status != "confirmed"

    result
  end

  def delete_event(event_id, send_notifications: true)
    service.delete_event("primary", event_id, send_notifications: send_notifications)
    
    true
  rescue e
    raise "Failed to delete event '#{event_id}': #{e.message}"
  end
  
  private

  def service
    @service ||= begin
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = credentials
      service
    end
  end

  def credentials
    @credentials ||= Google::Auth::UserRefreshCredentials.new(
      client_id: Global.config.google.client_id,
      client_secret: Global.config.google.client_secret,
      scope: "https://www.googleapis.com/auth/calendar",
      refresh_token: Global.config.google.refresh_token
    )
  end
end
