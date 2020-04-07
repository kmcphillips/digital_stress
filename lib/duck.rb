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
  COMMAND_PREFIXES = ["Duck", "duck"].freeze
  RESPONDERS = [
    SimpleResponder,
    TMinus,
    Alchemy,
  ].freeze

  class << self
    def quack
      QUACKS.sample
    end
  end

  attr_reader :bot, :datastore

  def initialize(token:)
    @token = token
    @datastore = Datastore.new
    @datastore.migrate
    @bot = Discordrb::Commands::CommandBot.new(
      token: token,
      prefix: COMMAND_PREFIXES,
      spaces_allowed: true,
      command_doesnt_exist_message: "Quack???"
    )
  end

  def join
    bot.reaction_add do |event|
      if event.emoji&.name == "🦆"
        user_id = event.user&.id
        message = event.message&.content
        server = event.server&.name
        channel = event.channel&.name

        if user_id && message.present? && server && channel
          datastore.learn(user_id: user_id, message: message, server: server, channel: channel)
          event.message.react("✅")
        else
          event.message.react("🚫")
        end
      end
    end

    bot.command :ping, description: "Hello, is it me you're looking for?" do |event, *params|
      PingCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    bot.command :steam, description: "Paste a link to the steam game matching the search." do |event, *params|
      SteamCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    bot.command [:image, :images], description: "Search for an image and post it." do |event, *params|
      ImageCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    bot.command :gif, description: "Search for a gif and post it." do |event, *params|
      GifCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    bot.command :status, description: "Check on status of the bot." do |event, *params|
      StatusCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    bot.command :learn, description: "Learn a phrase." do |event, *params|
      LearnCommand.new(event: event, bot: bot, params: params, datastore: datastore, typing: false).respond
    end

    bot.command :deploy, description: "Deploy an application." do |event, *params|
      DeployCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    # TODO
    # bot.command :games, description: "What should we play?" do |event, *params|
    #   GamesCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    # end

    bot.mention do |event|
      Log.info("mention #{event.author.name}: #{event.message.content}")

      # Answer the learned thing
      response = Duck.quack
      if event.server&.name
        learned = datastore.learned(server: event.server.name)
        response = learned.first if learned.present?
      end
      event.respond(response)
    end

    bot.message do |event|
      # duck is always watching
      Recorder.record(event, datastore: datastore)

      if event.channel.pm? && !COMMAND_PREFIXES.any?{ |c| event.message.content.starts_with?(c) }
        Log.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(Duck.quack)
      else # in a channel
        RESPONDERS.each { |responder| responder.new(event, bot: bot).respond }
      end
    end

    Log.info("Starting")

    bot.run
  end
end
