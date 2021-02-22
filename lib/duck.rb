# frozen_string_literal: true
class Duck
  COMMAND_PREFIXES = ["Duck", "duck"].freeze
  RESPONDERS = [
    SimpleResponder,
    TMinusResponder,
    AlchemyResponder,
    GoogleImageSearchResponder,
    TemperatureResponder,
  ].freeze
  COMMANDS = [
    { class_name: PingCommand, command: :ping, description: "Hello, is it me you're looking for?" },
    { class_name: SteamCommand, command: :steam, description: "Paste a link to the steam game matching the search." },
    { class_name: ImageCommand, command: :image, aliases: [:images], description: "Search for an image and post it." },
    { class_name: GifCommand, command: :gif, description: "Search for a gif and post it." },
    { class_name: StatusCommand, command: :status, description: "Check on status of the bot." },
    { class_name: LearnCommand, command: :learn, description: "Learn a phrase." },
    { class_name: DeployCommand, command: :deploy, description: "Deploy an application." },
    { class_name: OffTheRecordCommand, command: :off, description: "Go off the record." },
    { class_name: OnTheRecordCommand, command: :on, description: "Go back on the record." },
    { class_name: ChatCommand, command: :chat, description: "Chat like us. Can accept a username as an argument." },
    { class_name: WolframAlphaCommand, command: :wolfram, aliases: [:wa, :wolframalpha], description: "Query Wolfram|Alpha." },
    { class_name: TrainCommand, command: :train, description: "Train accidents." },
    { class_name: TextCommand, command: :text, description: "Send a text message. Name a person then the message to text them." },
    { class_name: AlchemyCommand, command: :tonight, description: "We playing games tonight? Who's coming?" },
    { class_name: GamesCommand, command: :games, aliases: [:game], description: "What should we play?" },
    { class_name: WikipediaCommand, command: :wikipedia, aliases: [:Wikipedia, :w, :wiki], description: "Search a topic on Wikipedia." },
  ].freeze

  attr_reader :bot

  def initialize(token:)
    @token = token
    @bot = Discordrb::Commands::CommandBot.new(
      token: token,
      prefix: COMMAND_PREFIXES,
      spaces_allowed: true,
      command_doesnt_exist_message: ->(event) {
        "Quack? Why is this so hard #{ event.user.mention }?"
      },
    )
    Global.bot = @bot
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

    COMMANDS.each do |command|
      bot.command(command[:command], description: command[:description], aliases: command[:aliases] || []) do |event, *params|
        command[:class_name].new(event: event, bot: bot, params: params).respond
      end
    end

    bot.mention do |event|
      Global.logger.info("mention #{event.author.name}: #{event.message.content}")
      event.channel.start_typing
      response = Learner.random_message(server: event.server&.name, prevent_recent: true) || Quacker.quack
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
        Global.logger.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(Quacker.quack)
      else # in a channel
        RESPONDERS.each do |responder|
          begin
            r = responder.new(event, bot: bot)
            r.respond if r.permitted?
          rescue => e
            Global.logger.error("#{ responder } returned error #{ e.message }")
            Global.logger.error(e)
            message = ":bangbang: Quack error in #{ responder }: #{ e.message }"
            event.respond(message)
          end
        end
      end
    end

    Global.logger.info("Starting")

    bot.run(true)

    WebDuck.run!
  end
end
