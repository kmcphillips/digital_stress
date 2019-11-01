# frozen_string_literal: true
class Quack
  BOT_NAMES = [
    "duck",
  ].freeze

  COMMANDS = [
    :ping,
  ]

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

  attr_reader :logger, :bot, :datastore

  def initialize(logger:, token:)
    @token = token
    @logger = logger
    @datastore = Datastore.new
    @bot = Discordrb::Bot.new(token: token)
  end

  def quack
    bot.mention do |event|
      handle_command(event)
      logger.info("mention #{event.author.name}: #{event.message.content}")
      event.respond(QUACKS.sample)
    end

    bot.message do |event|
      if event.channel.name == "general"
        datastore.append(event.author.name, event.message.content, event.timestamp)
        logger.info("datastore.append(#{event.author.name}, #{event.message.content}, #{event.timestamp})")
      end

      handle_command(event)

      if event.channel.pm?
        logger.info("pm #{event.author.name}: #{event.message.content}")
      end
    end

    logger.info("Starting")

    bot.run
  end

  private

  def ping(params:, event:)
    event.respond(":robot: Quack")
  end

  def run_command(command:, event:, params:)
    if COMMANDS.map{ |c| c.to_s.downcase }.include?(command)
      logger.info("command(#{ command }, '#{ params }')")
      send(command, params: params, event: event)
      true
    else
      logger.info("command #{ command } not found")
      event.respond(QUACKS.sample)
      false
    end
  end

  def handle_command(event)
    bot_mention = "<@#{ event.bot.profile.id }>"
    if event.message.content.split(" ", 2).first == bot_mention || BOT_NAMES.include?(event.message.content.split(" ", 2).first.downcase)
      parse_command(message: event.message.content.sub(/^[^ ]+ /, ''), event: event)
    elsif event.channel.pm?
      parse_command(message: event.message.content, event: event)
    else
      false
    end
  end

  def parse_command(message:, event:)
    command, params = message.split(" ", 2)
    run_command(command: command.downcase, event: event, params: params.presence || "")
  end
end
