# frozen_string_literal: true
class RedactCommand < BaseCommand
  DEFAULT_MINUTES = 15

  def response
    if event.channel.pm?
      "Quack, I can't redact DMs."
    elsif !Recorder.record_channel?(server: server, channel: channel)
      "Quack, I can't redact a channel I am not recording."
    else
      minutes = if query.blank?
        DEFAULT_MINUTES
      elsif matches = query.match(/(\d+\s?m)/)
        matches[1].to_i
      elsif matches = query.match(/(\d+\s?h)/)
        matches[1].to_i * 60
      end

      if !minutes
        "Quack, I don't know what you mean. Redact the default #{ DEFAULT_MINUTES } or specify a number of minutes/hours."
      elsif minutes <= 0
        "Quack, I can't redact #{ minutes } minutes."
      else
        deleted = Recorder.delete_last_minutes(minutes, server: server, channel: channel)

        ":pause_button: Quack, redacted #{ minutes } minutes of messages (#{ deleted.count } messages)."
      end
    end
  end
end
