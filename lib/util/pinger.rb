# frozen_string_literal: true
module Pinger
  extend self

  PING_REGEX = /\A<@\!([0-9]+)>/

  def extract_user_id(input)
    ping = PING_REGEX.match(input)
    ping[1].to_i if ping
  end

  def find_channel(server:, channel:)
    found_server = Global.bot.servers.values.find { |s| s.name == server.to_s }
    return nil unless found_server
    found_server.channels.find { |c| c.name == channel.to_s.gsub("#", "") }
  end
end
