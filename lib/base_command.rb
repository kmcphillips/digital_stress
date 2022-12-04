# frozen_string_literal: true
class BaseCommand
  attr_reader :params, :event, :bot, :user, :query

  MAX_MESSAGE_LENGTH = 1999

  def initialize(event:, bot:, params:)
    @bot = bot
    @params = params
    @query = params.join(" ")
    @event = event
    @user = User.from_discord(event.author, server: server)
  end

  def respond
    Global.logger.info("command.#{ @event.command.name }(#{ params })")
    @event.channel.start_typing if typing?

    return ":closed_lock_with_key: Quack! Not permitted!" if channels.present? && !channels.include?("#{ server }##{ channel }")

    begin
      message = response
      message = message.join("\n") if message.is_a?(Array)

      if message && message.is_a?(String) && message.length >= MAX_MESSAGE_LENGTH
        Global.logger.warn("response of length #{ message.length } is too long #{ message }")
        message = "#{ message.slice(0..(MAX_MESSAGE_LENGTH - 5))} ..."
      end

      Global.logger.info("response: #{ message }")
    rescue => e
      Global.logger.error("#{ self.class.name }#response returned error #{ e.message }")
      Global.logger.error(e)
      message = ":bangbang: Quack error: #{ e.message }"
    end
    message
  end

  def after(message:)
    nil
  end

  def server
    event.server&.name
  end

  def channel
    if !event.channel
      nil
    elsif event.channel.thread?
      event.channel.parent.name
    else
      event.channel.name
    end
  end

  def channels
    nil
  end

  def pm?
    event.channel.pm?
  end

  def thread?
    event.channel.thread?
  end

  def typing?
    true
  end

  private

  def response
    raise NotImplementedError
  end
end
