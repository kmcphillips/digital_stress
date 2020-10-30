# frozen_string_literal: true
class ChatAbsurdityRemberer
  CHANNELS = [
    "mandatemandate#general",
    "duck-bot-test#testing",
  ].freeze
  BACKOFF_SECONDS = 15..45
  ACTIVE_CONVERSATION_WINDOW_SECONDS = 120
  ACTIVE_CONVERSATION_PEOPLE = 2

  attr_reader :server, :channel

  def initialize(server:, channel:)
    @server = server
    @channel = channel

    raise "invalid server and channel #{ server }##{ channel }" unless server.present? && channel.present?
  end

  def enabled?
    !!KV.read(enabled_key)
  end

  def enabled_message
    if enabled?
      ":speaker: Absurdity is enabled."
    else
      ":mute: Absurdity is disabled."
    end
  end

  def enable
    KV.write(enabled_key, "true")
    true
  end

  def disable
    KV.delete(enabled_key)
    true
  end

  def note_conversation(user_id:)
    ids = JSON.parse(KV.read(conversation_key).presence || "[]")
    ids << user_id
    ids = ids.uniq
    KV.write(conversation_key, ids.to_json, ttl: ACTIVE_CONVERSATION_WINDOW_SECONDS)
    ids
  end

  def active_conversation?
    JSON.parse(KV.read(conversation_key).presence || "[]").count >= ACTIVE_CONVERSATION_PEOPLE
  end

  def in_backoff?
    !!KV.read(backoff_key)
  end

  def backoff
    backoff_time = rand(BACKOFF_SECONDS)
    puts "backoff #{ backoff_time }"
    Log.info("[#{ self.class }] Backing off for #{ backoff_time } seconds in #{ backoff_key }")
    KV.write(backoff_key, "true", ttl: backoff_time)
    true
  end

  def consume_message(user_id: nil)
    user_id ||= User::MANDATE_CONFIG_BY_ID.keys.sample
    user = User::MANDATE_CONFIG_BY_ID[user_id]
    username = user["username"]
    filename = File.join(File.dirname(__FILE__), "..", "absurdity_chats", "#{ user_id }.txt")

    lines = File.readlines(filename)
    lines = lines.shuffle
    message = lines.pop.strip

    File.open(filename, "w") { |f| f.write(lines.join("")) }

    { user_id: user_id, message: message }
  end

  private

  def enabled_key
    "chat-status-#{ server }-#{ channel }"
  end

  def backoff_key
    "chat-backoff-#{ server }-#{ channel }"
  end

  def conversation_key
    "chat-conversation-#{ server }-#{ channel }"
  end
end
