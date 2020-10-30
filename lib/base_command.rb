# frozen_string_literal: true
class BaseCommand
  attr_reader :params, :event, :bot, :user

  MAX_MESSAGE_LENGTH = 1999

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

    return ":closed_lock_with_key: Quack! Not permitted!" if channels.present? && !channels.include?("#{ server }##{ channel }")

    begin
      message = response
      message = message.join("\n") if message.is_a?(Array)

      if message && message.length >= MAX_MESSAGE_LENGTH
        Log.warn("response of length #{ message.length } is too long #{ message }")
        message = "#{ message.slice(0..(MAX_MESSAGE_LENGTH - 5))} ..."
      end

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

  def channels
    nil
  end

  private

  def response
    raise NotImplementedError
  end
end
