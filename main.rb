# frozen_string_literal: true
require_relative "base"

token = ENV["DISCORDRB_TOKEN"].presence

logger_file = File.open("bot.log", File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
logger = Logger.new(logger_file)
logger.level = Logger::INFO

raise "env var DISCORDRB_TOKEN must be set" unless token

begin
  Quack.new(token: token, logger: logger).quack
rescue => e
  logger.error("Exception in Quack#quack: #{e.message}")
  logger.error(e)
  logger.error(e.backtrace)
  raise
end
