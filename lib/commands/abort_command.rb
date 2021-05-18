# frozen_string_literal: true
class AbortCommand < BaseCommand
  attr_reader :previous_data

  def initialize(event:, bot:, params:)
    super
    @previous_data = Recorder.get_againable(server: server, channel: channel, user_id: event.author.id)
  end

  def response
    if previous_data
      server_channel = bot.servers.values.find {|s| s.name == server }.channels.find { |c| c.name == channel }
      message = server_channel.message(previous_data[:response_message_id])

      redacted_message = ":negative_squared_cross_mark:"
      message.edit(redacted_message)

      nil
    else
      "#{ Quacker.quack } :no_entry_sign: Nothing recent to abort."
    end
  end
end
