# frozen_string_literal: true
require_relative "base"

raise "discord token not set in config file" unless Global.config.discord.token.present?

begin
  Duck.new(token: Global.config.discord.token).run
rescue => e
  Global.logger.error("Exception in Duck#quack: #{e.message}")
  Global.logger.error(e)
  Global.logger.error(e.backtrace)
  raise
end
