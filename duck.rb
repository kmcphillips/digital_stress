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
  RECORD_CHANNELS = [
    "mandatemandate#general",
  ]
  RESPONDERS = [
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
    @bot = Discordrb::Commands::CommandBot.new(
      token: token,
      prefix: COMMAND_PREFIXES,
      spaces_allowed: true,
      command_doesnt_exist_message: "Quack???"
    )
  end

  def join
    bot.command :ping, description: "Hello, is it me you're looking for?" do |event, *params|
      Log.info("command.#{ event.command.name }(#{ params })")
      ":white_check_mark: #{ Duck.quack }"
    end

    bot.command :steam, description: "Paste a link to the steam game matching the search." do |event, *params|
      Log.info("command.#{ event.command.name }(#{ params })")
      search = params.join(" ")
      if search.blank?
        "Quacking-search for something"
      else
        event.channel.start_typing
        Steam.search_game_url(search) || "Quack-all found"
      end
    end

    bot.command [:image, :images], description: "Search for an image and post it." do |event, *params|
      Log.info("command.#{ event.command.name }(#{ params })")
      search = params.join(" ")
      if search.blank?
        "Quacking-search for something"
      else
        event.channel.start_typing
        Azure.search_image_url(search) || "Quack-all found"
      end
    end

    bot.command :gif, description: "Search for a gif and post it." do |event, *params|
      Log.info("command.#{ event.command.name }(#{ params })")
      search = params.join(" ")
      if search.blank?
        "Quacking-search for something"
      else
        event.channel.start_typing
        Gif.search_url(search) || "Quack-all found"
      end
    end

    bot.command :status, description: "Check on status of the bot." do |event, *params|
      StatusCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    bot.command :cluster, description: "How long until Cluster festival?" do |event, *params|
      ClusterCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    end

    # TODO
    # bot.command :games, description: "What should we play?" do |event, *params|
    #   GamesCommand.new(event: event, bot: bot, params: params, datastore: datastore).respond
    # end

    bot.mention do |event|
      Log.info("mention #{event.author.name}: #{event.message.content}")
      event.respond(Duck.quack)
    end

    bot.message do |event|
      # duck is always watching
      if record_event?(event)
        datastore.append(username: event.author.name, user_id: event.author.id, message: event.message.content, time: event.timestamp)
        Log.info("datastore.append(#{ { username: event.author.name, user_id: event.author.id, message: event.message.content, time: event.timestamp } }")
      end

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

  private

  def record_event?(event)
    if event.message.text.downcase.starts_with?("http") || event.message.text.downcase.starts_with?("duck ")
      Log.warn("record_event(false) ignoring : #{ event.message.text }")
      return false
    end
    RECORD_CHANNELS.each do |pair|
      server, channel = pair.split("#")
      return true if event.server&.name == server && event.channel&.name == channel
    end
    Log.warn("record_event(false) #{ event.server&.name || 'nil' }##{ event.channel&.name || 'nil' } : #{ event.message.text }")
    false
  end
end
