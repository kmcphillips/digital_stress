# frozen_string_literal: true
require_relative "base"

raise "discord token not set in config file" unless Configuration.discord.token.present?

begin
  Duck.new(token: Configuration.discord.token).run
rescue => e
  Log.error("Exception in Duck#quack: #{e.message}")
  Log.error(e)
  Log.error(e.backtrace)
  raise
end
