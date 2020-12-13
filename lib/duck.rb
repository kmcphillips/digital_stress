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
    TMinusResponder,
    AlchemyResponder,
    GoogleImageSearchResponder,
    TemperatureResponder,
  ].freeze

  class << self
    def quack
      QUACKS.sample
    end
  end

  attr_reader :bot

  def initialize(token:)
    @token = token
    @bot = Discordrb::Commands::CommandBot.new(
      token: token,
      prefix: COMMAND_PREFIXES,
      spaces_allowed: true,
      command_doesnt_exist_message: "Quack???"
    )
  end

  def run
    bot.reaction_add do |event|
      if Learner.learn_emoji?(event.emoji&.name)
        result = Learner.learn(
          user_id: event.user&.id,
          message_id: event.message&.id,
          message: event.message&.content,
          server: event.server&.name,
          channel: event.channel&.name,
        )

        if result
          event.message.react("✅")
        else
          event.message.react("🚫")
        end
      elsif Recorder.off_the_record_emoji?(event.emoji&.name)
        result = Recorder.delete(event)

        if result
          event.message.react("✅")
        else
          event.message.react("❓")
        end
      end
    end

    bot.reaction_remove do |event|
      if Learner.learn_emoji?(event.emoji&.name) && event.message&.id
        result = Learner.unlearn(message_id: event.message&.id)

        if result
          event.message.delete_own_reaction("✅")
        else
          event.message.react("❓")
        end
      end
    end

    bot.command :ping, description: "Hello, is it me you're looking for?" do |event, *params|
      PingCommand.new(event: event, bot: bot, params: params).respond
    end

    bot.command :steam, description: "Paste a link to the steam game matching the search." do |event, *params|
      SteamCommand.new(event: event, bot: bot, params: params).respond
    end

    bot.command [:image, :images], description: "Search for an image and post it." do |event, *params|
      ImageCommand.new(event: event, bot: bot, params: params).respond
    end

    bot.command :gif, description: "Search for a gif and post it." do |event, *params|
      GifCommand.new(event: event, bot: bot, params: params).respond
    end

    bot.command :status, description: "Check on status of the bot." do |event, *params|
      StatusCommand.new(event: event, bot: bot, params: params).respond
    end

    bot.command :learn, description: "Learn a phrase." do |event, *params|
      LearnCommand.new(event: event, bot: bot, params: params, typing: false).respond
    end

    bot.command :deploy, description: "Deploy an application." do |event, *params|
      DeployCommand.new(event: event, bot: bot, params: params).respond
    end

    bot.command :off, description: "Go off the record." do |event, *params|
      OffTheRecordCommand.new(event: event, bot: bot, params: { record: false }).respond
    end

    bot.command :on, description: "Go back on the record." do |event, *params|
      OffTheRecordCommand.new(event: event, bot: bot, params: { record: true }).respond
    end

    bot.command :chat, description: "Chat like us. Can accept a username as an argument." do |event, *params|
      ChatCommand.new(event: event, bot: bot, params: params).respond
    end

    bot.command [:wa, :wolfram, :wolframalpha], description: "Query Wolfram|Alpha." do |event, *params|
      WolframAlphaCommand.new(event: event, bot: bot, params: params).respond
    end

    # TODO
    # bot.command :games, description: "What should we play?" do |event, *params|
    #   GamesCommand.new(event: event, bot: bot, params: params).respond
    # end

    bot.mention do |event|
      Log.info("mention #{event.author.name}: #{event.message.content}")
      event.channel.start_typing
      response = Learner.random_message(server: event.server&.name, prevent_recent: true) || Duck.quack
      sleep(0.6)
      event.respond(response)
    end

    bot.message do |event|
      Recorder.record(event)
    end

    bot.message_edit do |event|
      Recorder.edit(event)
    end

    bot.message do |event|
      if event.channel.pm? && !COMMAND_PREFIXES.any?{ |c| event.message.content.starts_with?(c) }
        Log.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(Duck.quack)
      else # in a channel
        RESPONDERS.each do |responder|
          begin
            responder.new(event, bot: bot).respond
          rescue => e
            Log.error("#{ responder } returned error #{ e.message }")
            Log.error(e)
            message = ":bangbang: Quack error in #{ responder }: #{ e.message }"
            event.respond(message)
          end
        end
      end
    end

    Log.info("Starting")

    bot.run(true)

    WebDuck.bot = bot
    WebDuck.run!
  end
end
