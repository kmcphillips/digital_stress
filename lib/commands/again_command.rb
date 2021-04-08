# frozen_string_literal: true
class AgainCommand < BaseCommand
  attr_reader :previous_data

  def initialize(event:, bot:, params:)
    super
    @previous_data = Recorder.get_againable(server: server, channel: channel, user_id: event.author.id)
  end

  def response
    if previous_data
      server_channel = bot.servers.values.find {|s| s.name == server }.channels.find { |c| c.name == channel }
      message = server_channel.message(previous_data[:response_message_id])

      redacted_message = ":repeat:"
      message.edit(redacted_message)

      command_class = previous_data[:command_class].constantize
      command_class.new(event: event, bot: bot, params: [previous_data[:query]]).response
    else
      "#{ Quacker.quack } :no_entry_sign: Nothing recent to try again."
    end
  end

  def after(message)
    if previous_data
      Recorder.set_againable(
        command_class: previous_data[:command_class],
        query: previous_data[:query],
        query_user_id: event.author.id,
        query_message_id: event.message.id,
        response_user_id: message.author.id,
        response_message_id: message.id,
        server: server,
        channel: channel,
      )
    end
  end
end
