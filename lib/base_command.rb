# frozen_string_literal: true
class BaseCommand
  attr_reader :params

  def initialize(event:, bot:, params:, datastore:)
    @datastore = datastore
    @bot = bot
    @params = params
    @event = event
  end

  def respond
    Log.info("command.#{ @event.command.name }(#{ params })")
    @event.channel.start_typing
    begin
      message = response
      message = message.join("\n") if message.is_a?(Array)
      Log.info("response: #{ message }")
    rescue => e
      Log.error("#{ self.class.name }#response returned error #{ e.message }")
      Log.error(e)
      message = ":bangbang: Quack error: #{ e.message }"
    end
    message
  end

  private

  def response
    raise NotImplementedError
  end
end
