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
  T_MINUS_REGEX = /T-([^\s]+)\s?/i
  RECORD_CHANNELS = [
    "mandatemandate#general",
  ]

  attr_reader :bot, :datastore

  def initialize(token:)
    @token = token
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
      Log.info("command.#{ event.command.name }(#{ params })")
      ":white_check_mark: #{ QUACKS.sample }"
    end

    bot.command :steam, description: "Paste a link to the steam game matching the search." do |event, *params|
      Log.info("command.#{ event.command.name }(#{ params })")
      search = params.join(" ")
      if search.blank?
        "Quacking-search for something"
      else
        Steam.search_game_url(search) || "Quack-all found"
      end
    end

    bot.mention do |event|
      Log.info("mention #{event.author.name}: #{event.message.content}")
      event.respond(QUACKS.sample)
    end

    bot.message do |event|
      # duck is always watching
      if record_event?(event)
        datastore.append(event.author.name, event.message.content, event.timestamp)
        Log.info("datastore.append(#{event.author.name}, #{event.message.content}, #{event.timestamp})")
      end

      match = T_MINUS_REGEX.match(event.message.content)
      if match
        t_minus = match[1]
        Log.info("handle T-#{ t_minus }")
        # TODO
      end

      if event.channel.pm? && !event.message.content.starts_with?(COMMAND_PREFIX)
        Log.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(QUACKS.sample)
      end
    end

    Log.info("Starting")

    bot.run
  end

  private

  def record_event?(event)
    RECORD_CHANNELS.each do |pair|
      server, channel = pair.split("#")
      return true if event.server&.name == server && event.channel&.name == channel
    end
    Log.warn("record_event? == false : #{ event.server&.name || 'nil' }##{ event.channel&.name || 'nil' }")
    false
  end
end
