# frozen_string_literal: true
module Recorder
  extend self

  MESSAGE_IGNORED_PREFIXES = ["http", "duck ", ">", "`"].freeze
  RECORD_CHANNELS = [
    "mandatemandate#general",
    # "duck-bot-test#testing",
  ].freeze
  OFF_THE_RECORD_SECONDS = 2.hours

  def record(event)
    if record_event?(event)
      args = {
        username: event.author.name,
        user_id: event.author.id,
        message: event.message.content,
        message_id: event.message.id,
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

  def edit(event)
    table.where(message_id: event.message.id).update(message: event.message.content)
  end

  def record_event?(event)
    if ignore_message_content?(event)
      Log.warn("record_event(false) ignoring : #{ event.message.text }")
      return false
    end
    if record_channel?(server: event.server&.name, channel: event.channel&.name)
      if off_the_record?(server: event.server&.name, channel: event.channel&.name)
        Log.warn("record_event(false) because it is off the record #{ event.server&.name || 'nil' }##{ event.channel&.name || 'nil' } : #{ event.message.text }")
        false
      else
        true
      end
    else
      Log.warn("record_event(false) #{ event.server&.name || 'nil' }##{ event.channel&.name || 'nil' } : #{ event.message.text }")
      false
    end
  end

  def record_channel?(server:, channel:)
    RECORD_CHANNELS.each do |pair|
      record_server, record_channel = pair.split("#")
      return true if server == record_server && channel == record_channel
    end
    false
  end

  def record_server?(server:)
    RECORD_CHANNELS.each do |pair|
      record_server, record_channel = pair.split("#")
      return true if server == record_server
    end
    false
  end

  def counts
    DB["SELECT DISTINCT username, user_id, COUNT(*) AS count FROM messages GROUP BY username ORDER BY username ASC"].all
  end

  def last
    DB["SELECT username, user_id, message, timestamp, server, channel FROM messages ORDER BY timestamp DESC LIMIT 1"].first
  end

  def off_the_record?(server:, channel:)
    !!KV.read(otr_key(server: server, channel: channel))
  end

  def off_the_record(server:, channel:)
    KV.write(otr_key(server: server, channel: channel), "1", ttl: OFF_THE_RECORD_SECONDS.to_i)
    OFF_THE_RECORD_SECONDS.to_i
  end

  def on_the_record(server:, channel:)
    KV.delete(otr_key(server: server, channel: channel))
    true
  end

  private

  def table
    DB[:messages]
  end

  def ignore_message_content?(event)
    text = event.message.text.downcase

    text.blank? || MESSAGE_IGNORED_PREFIXES.any? { |prefix| text.starts_with?(prefix) }
  end

  def otr_key(server:, channel:)
    "off_the_record:#{ server }:#{ channel }"
  end
end
