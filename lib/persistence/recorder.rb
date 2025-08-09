# frozen_string_literal: true

module Recorder
  extend self

  MESSAGE_IGNORED_PREFIXES = ["http", "duck ", ">", "`"].freeze
  IGNORED_USER_IDS = [
    936929561302675456 # Midjourney Bot
  ].freeze
  RECORD_CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#dnd"
    # "duck-bot-test#testing",
  ].freeze
  OFF_THE_RECORD_SECONDS = 2.hours
  OFF_THE_RECORD_EMOJI = [
    "⏸️",
    "❎"
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
        channel: event.channel.name
      }

      Global.logger.info("record(#{args}")
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

  def delete_last_minutes(minutes, server:, channel:)
    table
      .where(server: server, channel: channel)
      .where { timestamp > (Time.now - minutes.minutes).to_i }
      .map do |r|
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
    delete_matching { |r| ignore_message_content?(r[:message]) || ignore_user?(r[:user_id]) }
  end

  def record_event?(event)
    if ignore_message_content?(event.message.text) || ignore_user?(event.author.id)
      Global.logger.warn("record_event(false) ignoring : #{event.message.text}")
      false
    elsif record_channel?(server: event.server&.name, channel: event.channel&.name)
      if off_the_record?(server: event.server&.name, channel: event.channel&.name)
        Global.logger.warn("record_event(false) because it is off the record #{event.server&.name || "nil"}##{event.channel&.name || "nil"} : #{event.message.text}")
        false
      else
        true
      end
    else
      Global.logger.warn("record_event(false) #{event.server&.name || "nil"}##{event.channel&.name || "nil"} : #{event.message.text}")
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
      record_server, _ = pair.split("#")
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
      .where { timestamp > (Time.now - time_offset).to_i }
      .order(Sequel.desc(:timestamp))
      .limit(limit)
  end

  def all_since(server:, channel:, since:)
    table
      .where(server: server, channel: channel)
      .where { timestamp > since.to_i }
      .order(Sequel.desc(:timestamp))
  end

  def off_the_record?(server:, channel:)
    !!kv_store.read(otr_key(server: server, channel: channel))
  end

  def off_the_record(server:, channel:, seconds: nil)
    seconds = (seconds || OFF_THE_RECORD_SECONDS).to_i
    raise "Invalid seconds #{seconds}" if seconds <= 0
    kv_store.write(otr_key(server: server, channel: channel), "1", ttl: seconds)
    seconds
  end

  def on_the_record(server:, channel:)
    kv_store.delete(otr_key(server: server, channel: channel))
    true
  end

  def off_the_record_emoji?(emoji)
    OFF_THE_RECORD_EMOJI.include?(emoji)
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
      redaction_action: redaction_action
    }
    key = againable_key(server: server, channel: channel, user_id: query_user_id)

    kv_store.write(key, data.to_json, ttl: AGAIN_COMMAND_SECONDS.to_i)
    AGAIN_COMMAND_SECONDS.to_i
  end

  def get_againable(server:, channel:, user_id:)
    data = kv_store.read(againable_key(server: server, channel: channel, user_id: user_id))
    begin
      JSON.parse(data).symbolize_keys
    rescue
      nil
    end
  end

  def set_message_metadata(message_id, type, metadata)
    message_id = message_id.id if message_id.is_a?(Discordrb::Message)
    message_id = message_id.to_s

    Global.db.transaction do
      Global.db[:message_metadata].where(message_id: message_id, type: type.to_s).delete
      Global.db[:message_metadata].insert(message_id: message_id, type: type.to_s, value: metadata)
    end

    true
  end

  def get_message_metadata(message_id, type = nil)
    message_id = message_id.id if message_id.is_a?(Discordrb::Message)
    message_id = message_id.to_s

    if type.present?
      Global.db[:message_metadata].where(message_id: message_id, type: type.to_s).first&.dig(:value)
    else
      Global.db[:message_metadata].where(message_id: message_id).all.map { |r| [r[:type], r[:value]] }.to_h
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

  def ignore_user?(user_id)
    IGNORED_USER_IDS.include?(user_id.to_i)
  end

  def otr_key(server:, channel:)
    "off_the_record:#{server}:#{channel}"
  end

  def againable_key(server:, channel:, user_id:)
    raise "invalid againable_key #{server} / #{channel} / #{user_id}" if [server, channel, user_id].any?(&:blank?)
    "againable:#{server}:#{channel}:#{user_id}"
  end
end
