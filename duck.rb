# frozen_string_literal: true
class Duck
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

  COMMAND_PREFIX = "duck"

  attr_reader :logger, :bot, :datastore

  def initialize(logger:, token:)
    @token = token
    @logger = logger
    @datastore = Datastore.new
    @bot = Discordrb::Commands::CommandBot.new(
      token: token,
      prefix: COMMAND_PREFIX,
      spaces_allowed: true,
      command_doesnt_exist_message: "Quack???"
    )
  end

  def quack
    bot.command :ping, description: "Hello, is it me you're looking for?" do |event, *params|
      ":white_check_mark: #{ QUACKS.sample }"
    end

    bot.command :steam, description: "Paste a link to the steam game matching the search." do |event, *params|
      search = params.join(" ")
      if search.blank?
        "Quacking-search for something"
      else
        Steam.search_game_url(search) || "Quack-all found"
      end
    end

    bot.mention do |event|
      logger.info("mention #{event.author.name}: #{event.message.content}")
      event.respond(QUACKS.sample)
    end

    bot.message do |event|
      # duck is always watching
      if event.channel.name == "general"
        datastore.append(event.author.name, event.message.content, event.timestamp)
        logger.info("datastore.append(#{event.author.name}, #{event.message.content}, #{event.timestamp})")
      end

      if event.channel.pm? && !event.message.content.starts_with?(COMMAND_PREFIX)
        logger.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(QUACKS.sample)
      end
    end

    logger.info("Starting")

    bot.run
  end
end
