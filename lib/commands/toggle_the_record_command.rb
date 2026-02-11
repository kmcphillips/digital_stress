# frozen_string_literal: true

class ToggleTheRecordCommand < BaseCommand
  MAX_MINUTES = (60 * 24 * 3) + 1

  def allowed_in_pm?
    false
  end

  def response
    if Recorder.record_channel?(channel: channel, server: server)
      if record? # on the record
        Recorder.on_the_record(server: server, channel: channel)
        ":record_button: This channel is on the record"
      elsif params[0].present? # off the record, with minutes
        minutes = Formatter.parse_minutes_from(params[0])

        if minutes && minutes < MAX_MINUTES
          seconds = Recorder.off_the_record(server: server, channel: channel, seconds: minutes * 60)
          ":pause_button: This channel is off the record for #{distance_in_words(seconds)}"
        else
          ":bangbang: Cannot figure out how many minutes #{params[0]} is"
        end
      else # off the record, default
        seconds = Recorder.off_the_record(server: server, channel: channel)
        ":pause_button: This channel is off the record for #{distance_in_words(seconds)}"
      end
    else
      "Quack, this channel is not set to record."
    end
  end

  def record?
    raise NotImplementedError
  end

  private

  def distance_in_words(seconds)
    t = Time.now
    TimeDifference.between(t, t + seconds).humanize.downcase
  end
end

class OffTheRecordCommand < ToggleTheRecordCommand
  def record?
    false
  end
end

class OnTheRecordCommand < ToggleTheRecordCommand
  def record?
    true
  end
end
