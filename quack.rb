# frozen_string_literal: true
class Quack
  QUACKS = [
    "Quack",
    "Quack.",
    "Hwain",
    "Quack quack",
    "Quack!",
    "Quack?",
    "quack",
    "quack quack quack",
    "Quack, Quack",
    "Quack",
  ].freeze

  attr_reader :logger, :bot

  def initialize(logger:, token:)
    @token = token
    @logger = logger
    @bot = Discordrb::Bot.new(token: token)
  end

  def quack
    bot.mention do |event|
      logger.info("mention #{event.author.name}: #{event.message.content}")
      event.respond(QUACKS.sample)
    end

    bot.message do |event|
      if event.channel.pm?
        logger.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(QUACKS.sample)
      end
    end

    logger.info("Starting")

    bot.run
  end

  private
end
