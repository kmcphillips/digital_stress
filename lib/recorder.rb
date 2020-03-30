# frozen_string_literal: true
module Recorder
  extend self

  MESSAGE_IGNORED_PREFIXES = ["http", "duck ", ">", "`"].freeze
  RECORD_CHANNELS = [
    "mandatemandate#general",
  ]

  def record(event, datastore:)
    if record_event?(event)
      datastore.append(username: event.author.name, user_id: event.author.id, message: event.message.content, time: event.timestamp, server: event.server.name, channel: event.channel.name)
      Log.info("datastore.append(#{ { username: event.author.name, user_id: event.author.id, message: event.message.content, time: event.timestamp, server: event.server.name, channel: event.channel.name } }")

      true
    else
      false
    end
  end

  def record_event?(event)
    if ignore_message_content?(event)
      Log.warn("record_event(false) ignoring : #{ event.message.text }")
      return false
    end
    RECORD_CHANNELS.each do |pair|
      server, channel = pair.split("#")
      return true if event.server&.name == server && event.channel&.name == channel
    end
    Log.warn("record_event(false) #{ event.server&.name || 'nil' }##{ event.channel&.name || 'nil' } : #{ event.message.text }")
    false
  end

  def record_server?(event)
    RECORD_CHANNELS.each do |pair|
      server, channel = pair.split("#")
      return true if event.server&.name == server
    end
    false
  end

  private

  def ignore_message_content?(event)
    text = event.message.text.downcase

    text.blank? || MESSAGE_IGNORED_PREFIXES.any? { |prefix| text.starts_with?(prefix) }
  end
end
