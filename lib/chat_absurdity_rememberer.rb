# frozen_string_literal: true
class ChatAbsurdityRemberer
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

  private

  def enabled_key
    "chat-status-#{ server }-#{ channel }"
  end

end
