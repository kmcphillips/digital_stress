# frozen_string_literal: true

class BaseResponder
  attr_reader :event, :bot

  def initialize(event, bot:)
    @event = event
    @bot = bot
  end

  def respond
    raise NotImplementedError
  end

  def text
    event.message.content
  end

  def mention
    event.user.mention
  end

  def user
    event.user
  end

  def server
    event.server&.name
  end

  def channel
    event.channel&.name
  end

  def attached_images
    event.message.attachments.select { |a| a.image? }
  end

  def channels
    nil
  end

  def permitted?
    return true unless channels
    return true unless channels.any?
    channels.include?("#{server}##{channel}") || channels.include?(server.to_s)
  end

  def start_typing
    event.channel&.start_typing
  end

  def while_typing(&block)
    WithTyping.threaded(event.channel, &block)
  end
end
