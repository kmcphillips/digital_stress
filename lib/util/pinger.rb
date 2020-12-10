# frozen_string_literal: true
module Pinger
  extend self

  PING_REGEX = /\A<@\!([0-9]+)>/

  def extract_user_id(input)
    ping = PING_REGEX.match(input)
    ping[1].to_i if ping
  end
end
