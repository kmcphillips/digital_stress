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
  T_MINUS_NUMBER_REGEX = /T-([0-9]+)/i
  RECORD_CHANNELS = [
    "mandatemandate#general",
  ]

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
      Log.info("command.#{ event.command.name }(#{ params })")
      event.channel.start_typing
      ip_address = `hostname`.strip
      hostname = `hostname -I`.split(" ").first
      counts = datastore.counts
      last = datastore.last
      lines = [
        ":duck: on `#{ hostname }` `(#{ ip_address })`",
        "Last message by **#{ last[0] }** #{ TimeDifference.between(Time.at(last[3]), Time.now).humanize || 'a second' } ago",
      ] + counts.map{ |r| "  **#{ r[0] }**: #{ r[2] } messages" }
      lines.reject(&:blank?).join("\n")
    end

    bot.mention do |event|
      Log.info("mention #{event.author.name}: #{event.message.content}")
      event.respond(QUACKS.sample)
    end

    bot.message do |event|
      # duck is always watching
      if record_event?(event)
        datastore.append(username: event.author.name, user_id: event.author.id, message: event.message.content, time: event.timestamp)
        Log.info("datastore.append(#{ { username: event.author.name, user_id: event.author.id, message: event.message.content, time: event.timestamp } }")
      end

      if event.channel.pm? && !COMMAND_PREFIXES.any?{ |c| event.message.content.starts_with?(c) }
        Log.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(QUACKS.sample)
      else # in a channel
        match = T_MINUS_NUMBER_REGEX.match(event.message.content)
        if match
          minutes = match[1].to_i
          channel_id = event.channel.id
          mention = event.user.mention
          Log.info("handle T-#{ minutes } from: #{ event.message.content }")

          if minutes > 300
            event.respond("T-#{ minutes } minutes is too long to wait #{ mention }")
          else
            event.respond("T-#{ minutes } minutes and counting #{ mention }")
            Thread.new do
              sleep(minutes * 60)
              event.channel.start_typing
              sleep(2)
              online = event.server.voice_channels.map{ |c| c.users.map(&:id) }.flatten.include?(event.user.id)
              if online
                bot.send_message(channel_id, "T-#{ minutes } minutes is up and #{ mention } made it on time :ok_hand:")
              else
                bot.send_message(channel_id, "T-#{ minutes } minutes is up and #{ mention } is late :alarm_clock:")
              end
            end
          end
        end
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
