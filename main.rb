require "pry"
require "active_support/all"
require "dotenv/load"
require "discordrb"
require "logger"

token = ENV["DISCORDRB_TOKEN"].presence

logger_file = File.open("bot.log", File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
logger = Logger.new(logger_file)
logger.level = Logger::INFO

raise "env var DISCORDRB_TOKEN must be set" unless token

bot = Discordrb::Bot.new(token: token)

bot.mention do |event|
  logger.info("mention #{event.author.name}: #{event.message.content}")
  event.respond("I'm a secret to everybody.")
end

bot.message do |event|
  if event.channel.pm?
    logger.info("pm #{event.author.name}: #{event.message.content}")
    event.respond("Yes, tell me more.")
  end
end

logger.info("Starting")

bot.run
