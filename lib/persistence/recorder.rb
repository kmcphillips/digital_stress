# frozen_string_literal: true
module Recorder
  extend self

  MESSAGE_IGNORED_PREFIXES = ["http", "duck ", ">", "`"].freeze
  RECORD_CHANNELS = [
    "mandatemandate#general",
    # "duck-bot-test#testing",
  ].freeze
  OFF_THE_RECORD_SECONDS = 2.hours
  OFF_THE_RECORD_EMOJI = [
    "⏸️",
    "🚫",
    "❎",
  ].freeze

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

      Global.logger.info("record(#{ args }")
      table.insert(args)

      true
    else
      false
    end
  end

  def edit(event)
    table.where(message_id: event.message.id).update(message: event.message.content)
  end

  def delete(event)
    return nil unless event.message&.id
    table.where(message_id: event.message.id).delete
  end

  def delete_last(n)
    table.order(Sequel.desc(:timestamp)).limit(n).map do |r|
      table.where(id: r[:id]).delete
      r
    end
  end

  def delete_matching(&block)
    table.map do |r|
      if yield(r)
        table.where(id: r[:id]).delete
        r
      end
    end.compact
  end

  def delete_sweep
    delete_matching { |r| ignore_message_content?(r[:message]) }
  end

  def record_event?(event)
    if ignore_message_content?(event.message.text)
      Global.logger.warn("record_event(false) ignoring : #{ event.message.text }")
      return false
    end
    if record_channel?(server: event.server&.name, channel: event.channel&.name)
      if off_the_record?(server: event.server&.name, channel: event.channel&.name)
        Global.logger.warn("record_event(false) because it is off the record #{ event.server&.name || 'nil' }##{ event.channel&.name || 'nil' } : #{ event.message.text }")
        false
      else
        true
      end
    else
      Global.logger.warn("record_event(false) #{ event.server&.name || 'nil' }##{ event.channel&.name || 'nil' } : #{ event.message.text }")
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

  # TODO: Scope by :server
  def counts
    Global.db["SELECT DISTINCT user_id, COUNT(*) AS count, sum(length(message) - length(replace(message, ' ', ''))+1) AS words FROM messages GROUP BY user_id ORDER BY count DESC"].all
  end

  # TODO: Scope by :server
  def last
    Global.db["SELECT username, user_id, message, timestamp, server, channel FROM messages ORDER BY timestamp DESC LIMIT 1"].first
  end

  def off_the_record?(server:, channel:)
    !!kv_store.read(otr_key(server: server, channel: channel))
  end

  def off_the_record(server:, channel:)
    kv_store.write(otr_key(server: server, channel: channel), "1", ttl: OFF_THE_RECORD_SECONDS.to_i)
    OFF_THE_RECORD_SECONDS.to_i
  end

  def on_the_record(server:, channel:)
    kv_store.delete(otr_key(server: server, channel: channel))
    true
  end

  def off_the_record_emoji?(emoji)
    OFF_THE_RECORD_EMOJI.include?(emoji)
  end

  def dump
    table.each_with_object({}) do |r, accu|
      accu[r[:user_id]] ||= { username: r[:username], messages: [] }
      accu[r[:user_id]][:messages] << r[:message]
      accu[r[:user_id]][:username] = r[:username]
    end
  end

  private

  def table
    Global.db[:messages]
  end

  def kv_store
    Global.kv
  end

  def ignore_message_content?(text)
    text = text.downcase

    # TODO technically this isn't correct as the AlchemyResponder should also filter on server and channel to know
    text.blank? || MESSAGE_IGNORED_PREFIXES.any? { |prefix| text.starts_with?(prefix) } || AlchemyResponder.element_from_message(text).present?
  end

  def otr_key(server:, channel:)
    "off_the_record:#{ server }:#{ channel }"
  end
end
