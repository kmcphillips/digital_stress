# frozen_string_literal: true
class AgainCommand < BaseCommand
  def response
    if previous_data = Recorder.get_againable(server: server, channel: channel, user_id: event.author.id)
      # This is a gross hack to get them to chain
      # the #after method is called creating a new record pointing to the new reply
      @command_class_name = previous_data[:command_class]
      @query = previous_data[:query]

      server_channel = bot.servers.values.find {|s| s.name == server }.channels.find { |c| c.name == channel }
      message = server_channel.message(previous_data[:response_message_id])

      redacted_message = ":repeat:"
      message.edit(redacted_message)

      command_class = previous_data[:command_class].constantize
      command_class.new(event: event, bot: bot, params: [previous_data[:query]]).response
    else
      "#{ Quacker.quack } nothing recent to try again."
    end
  end

  def after(message)
    Recorder.set_againable(
      command_class: @command_class_name,
      query: @query,
      query_user_id: event.author.id,
      query_message_id: event.message.id,
      response_user_id: message.author.id,
      response_message_id: message.id,
      server: server,
      channel: channel,
    )
  end
end
