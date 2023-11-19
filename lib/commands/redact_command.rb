# frozen_string_literal: true
class RedactCommand < BaseCommand
  DEFAULT_MINUTES = 15

  def response
    if event.channel.pm?
      server_channel_token, redact_time = query.split(" ", 2)
      redact_server, redact_channel = server_channel_token.split("#", 2)

      return "Quack, can't parse server#channel from '#{ server_channel_token }'." if redact_server.blank? || redact_channel.blank?
    else
      redact_server = server
      redact_channel = channel
      redact_time = query
    end

    if !Recorder.record_channel?(server: redact_server, channel: redact_channel)
      "Quack, I can't redact a channel I am not recording."
    else
      minutes = if redact_time.blank?
        DEFAULT_MINUTES
      elsif matches = redact_time.match(/(\d+\s?m)/)
        matches[1].to_i
      elsif matches = redact_time.match(/(\d+\s?h)/)
        matches[1].to_i * 60
      end

      if !minutes
        "Quack, I don't know what you mean. Redact the default #{ DEFAULT_MINUTES } or specify a number of minutes/hours."
      elsif minutes <= 0
        "Quack, I can't redact #{ minutes } minutes."
      else
        deleted = Recorder.delete_last_minutes(minutes, server: redact_server, channel: redact_channel)

        if event.channel.pm?
          ":pause_button: Quack, redacted #{ minutes } minutes of messages in **#{ redact_server }##{ redact_channel }** (#{ deleted.count } messages)."
        else
          ":pause_button: Quack, redacted #{ minutes } minutes of messages (#{ deleted.count } messages)."
        end
      end
    end
  end
end
