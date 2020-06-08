# frozen_string_literal: true
require_relative "base"

token = ENV["DISCORDRB_TOKEN"].presence

raise "env var DISCORDRB_TOKEN must be set" unless token

begin
  Duck.new(token: token).run
rescue => e
  Log.error("Exception in Duck#quack: #{e.message}")
  Log.error(e)
  Log.error(e.backtrace)
  raise
end
