# frozen_string_literal: true

class BaseCommand
  attr_reader :params, :event, :bot, :user, :query

  def initialize(event:, bot:, params:)
    @bot = bot
    @params = params
    @query = params.join(" ")
    @event = event
    @user = User.from_discord(event.author, server: server)
  end

  def respond
    Global.logger.info("command.#{@event.command.name}(#{params})")

    WithTyping.threaded(event.channel, enable: typing?) do
      if channels.present? && !(channels.include?("#{server}##{channel}") || channels.include?(server.to_s))
        ":closed_lock_with_key: Quack! Not permitted!"
      else
        begin
          message = response
          message = message.join("\n") if message.is_a?(Array)

          if Formatter.too_long?(message)
            Global.logger.warn("[#{self.class.name}#response] response of length #{message.length} is too long #{message}")
            message = Formatter.truncate_too_long(message)
          end

          Global.logger.info("response: #{message}")
        rescue => e
          Global.logger.error("#{self.class.name}#response returned error #{e.message}")
          Global.logger.error(e)
          message = ":bangbang: Quack error: #{e.message}"
        end
        message
      end
    end
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

  def attached_images
    event.message.attachments.select { |a| a.image? }
  end

  private

  def response
    raise NotImplementedError
  end
end
