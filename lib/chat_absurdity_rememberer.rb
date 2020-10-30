# frozen_string_literal: true
class ChatAbsurdityRemberer
  CHANNELS = [
    "mandatemandate#general",
    "duck-bot-test#testing",
  ].freeze
  BACKOFF_SECONDS = 5..45
  ACTIVE_CONVERSATION_WINDOW_SECONDS = 120

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
    JSON.parse(KV.read(conversation_key).presence || "[]").count >= 2
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
