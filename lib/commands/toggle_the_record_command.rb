# frozen_string_literal: true
class ToggleTheRecordCommand < BaseCommand
  def response
    if Recorder.record_channel?(channel: channel, server: server)
      if record?
        Recorder.on_the_record(server: server, channel: channel)
        ":record_button: This channel is on the record"
      else
        seconds = Recorder.off_the_record(server: server, channel: channel)
        ":pause_button: This channel is off the record for #{ distance_in_words(seconds) }"
      end
    else
      ":bangbang: This channel is not set to record."
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
