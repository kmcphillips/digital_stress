# frozen_string_literal: true

class AbortCommand < BaseCommand
  attr_reader :previous_data

  def initialize(event:, bot:, params:)
    super
    @previous_data = Recorder.get_againable(server: server, channel: channel, user_id: event.author.id)
  end

  def response
    if previous_data
      server_channel = bot.servers.values.find { |s| s.name == server }.channels.find { |c| c.name == channel }
      message = server_channel.message(previous_data[:response_message_id])

      if previous_data[:redaction_action].present?
        redacted_message = case previous_data[:redaction_action].intern
        when :strikethrough
          "~~#{message.content}~~"
        when :redact
          ":negative_squared_cross_mark:"
        else
          ":negative_squared_cross_mark:"
        end

        message.edit(redacted_message)
      end

      nil
    else
      "#{Quacker.quack} :no_entry_sign: Nothing recent to abort."
    end
  end

  def typing?
    false
  end
end
