# frozen_string_literal: true
class BaseCommand
  attr_reader :params, :event, :bot, :user

  def initialize(event:, bot:, params:, typing: true)
    @bot = bot
    @params = params
    @event = event
    @typing = typing
    @user = User.from_discord(event.author)
  end

  def respond
    Log.info("command.#{ @event.command.name }(#{ params })")
    @event.channel.start_typing if @typing
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

  def server
    event.server&.name
  end

  def channel
    event.channel&.name
  end

  private

  def response
    raise NotImplementedError
  end
end
