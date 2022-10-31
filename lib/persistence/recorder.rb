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
  AGAIN_COMMAND_SECONDS = 1.hour

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
    id = if event.respond_to?(:message)
      event.message&.id
    else
      event.id
    end

    table.where(message_id: id).delete if id
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

  def counts(server:)
    Global.db["SELECT DISTINCT user_id, COUNT(*) AS count, cast(sum(length(message) - length(replace(message, ' ', ''))+1) AS UNSIGNED) AS words FROM messages WHERE server = ? GROUP BY user_id ORDER BY count DESC", server].all
  end

  def last(server:)
    Global.db["SELECT username, user_id, message, timestamp, server, channel FROM messages WHERE server = ? ORDER BY timestamp DESC LIMIT 1", server].first
  end

  def recent(server:, channel:, limit: 15, time_offset: 30.minutes)
    table
      .where(server: server, channel: channel)
      .where{ timestamp > (Time.now - time_offset).to_i }
      .order(Sequel.desc(:timestamp))
      .limit(limit)
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

  def set_againable(command_class:, query:, query_user_id:, query_message_id:, response_user_id:, response_message_id:, server:, channel:, redaction_action: nil, subcommand: nil)
    data = {
      command_class: command_class,
      query: query,
      query_user_id: query_user_id,
      query_message_id: query_message_id,
      response_user_id: response_user_id,
      response_message_id: response_message_id,
      server: server,
      channel: channel,
      subcommand: subcommand,
      redaction_action: redaction_action,
    }
    key = againable_key(server: server, channel: channel, user_id: query_user_id)

    kv_store.write(key, data.to_json, ttl: AGAIN_COMMAND_SECONDS.to_i)
    AGAIN_COMMAND_SECONDS.to_i
  end

  def get_againable(server:, channel:, user_id:)
    data = kv_store.read(againable_key(server: server, channel: channel, user_id: user_id))
    JSON.parse(data).symbolize_keys rescue nil
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

  def againable_key(server:, channel:, user_id:)
    raise "invalid againable_key #{ server } / #{ channel } / #{ user_id }" if [server, channel, user_id].any?(&:blank?)
    "againable:#{ server }:#{ channel }:#{ user_id }"
  end
end
