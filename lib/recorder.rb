# frozen_string_literal: true
module Recorder
  extend self

  MESSAGE_IGNORED_PREFIXES = ["http", "duck ", ">", "`"].freeze
  RECORD_CHANNELS = [
    "mandatemandate#general",
    # "duck-bot-test#testing",
  ]

  def record(event)
    if record_event?(event)
      args = {
        username: event.author.name,
        user_id: event.author.id,
        message: event.message.content,
        timestamp: Formatter.parse_timestamp(event.timestamp),
        server: event.server.name,
        channel: event.channel.name,
      }

      Log.info("record(#{ args }")
      table.insert(args)

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

  def record_channel?(event)
    RECORD_CHANNELS.each do |pair|
      server, channel = pair.split("#")
      return true if event.server&.name == server
    end
    false
  end

  def counts
    DB["SELECT DISTINCT username, user_id, COUNT(*) AS count FROM messages GROUP BY username ORDER BY username ASC"].all
  end

  def last
    DB["SELECT username, user_id, message, timestamp, server, channel FROM messages ORDER BY timestamp DESC LIMIT 1"].first
  end

  private

  def table
    DB[:messages]
  end

  def ignore_message_content?(event)
    text = event.message.text.downcase

    text.blank? || MESSAGE_IGNORED_PREFIXES.any? { |prefix| text.starts_with?(prefix) }
  end
end
