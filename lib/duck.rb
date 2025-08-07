# frozen_string_literal: true

class Duck
  COMMAND_PREFIXES = ["Duck", "duck"].freeze
  RESPONDERS = [
    SimpleResponder,
    TMinusResponder,
    AlchemyResponder,
    # GoogleImageSearchResponder,
    TemperatureResponder,
    TopicResponder,
    AiResponder
  ].freeze
  COMMANDS = [
    {class_name: PingCommand, command: :ping, description: "Hello, is it me you're looking for?"},
    {class_name: SteamCommand, command: :steam, description: "Search for Steam games."},
    {class_name: ImageCommand, command: :image, aliases: [:images], description: "Search for images."},
    {class_name: GifCommand, command: :gif, description: "Search for a gif."},
    {class_name: StatusCommand, command: :status, description: "Check on status of the duck bot."},
    {class_name: LearnCommand, command: :learn, description: "Learn something."},
    {class_name: OffTheRecordCommand, command: :off, description: "Go off the record."},
    {class_name: OnTheRecordCommand, command: :on, description: "Go back on the record."},
    {class_name: RedactCommand, command: :redact, description: "Retroactively go off the record for the passed in number of minutes/hours."},
    {class_name: WolframAlphaCommand, command: :wolfram, aliases: [:wa, :wolframalpha], description: "Query Wolfram|Alpha."},
    {class_name: TrainCommand, command: :train, description: "Train accidents."},
    {class_name: TextCommand, command: :text, description: "Send a text message to a person by name."},
    {class_name: AlchemyCommand, command: :tonight, description: "We playing games tonight? Who's coming?"},
    {class_name: GamesCommand, command: :games, aliases: [:game], description: "What should we play?"},
    {class_name: WikipediaCommand, command: :wikipedia, aliases: [:Wikipedia, :w, :wiki], description: "Search a topic on Wikipedia."},
    {class_name: AgainCommand, command: :again, aliases: [:retry, :try, :redo], description: "Redo and remove the last search or prompt."},
    {class_name: MoreCommand, command: :more, description: "Redo and keep the last search or prompt."},
    {class_name: AbortCommand, command: :abort, description: "Give up redoing the search or prompt."},
    {class_name: AnnouncementCommand, command: :announcement, aliases: [:announcements], description: "Manage the announcements."},
    {class_name: NotificationsCommand, command: :notifications, aliases: [:notification, :notify], description: "Silence notifications."},
    {class_name: RollCommand, command: :roll, aliases: [:r], description: "Roll some dice."},
    {class_name: DndCommand, command: :dnd, aliases: [:DND], description: "D&D 5e commands."},
    {class_name: QuigitalCommand, command: :quigital, description: "Engage with Quigital!"},
    {class_name: OpenaiCommand, command: :openai, aliases: [:ai], description: "Commands relating to OpenAI."},
    {class_name: OpenaiChatCommand, command: :chat, description: "Chat using OpenAI's latest model."},
    {class_name: ImagineCommand, command: :imagine, description: "Imagine something with AI."},
    {class_name: ReimagineCommand, command: :reimagine, description: "Imagine something with AI, feeding the text into the image."},
    {class_name: HaikuCommand, command: :haiku, description: "Compose a haiku GPT-4."},
    {class_name: WhatCommand, command: :what, description: "What do you think?"},
    {class_name: RecipeCommand, command: :recipe, description: "Create a recipe using GPT-4"},
    {class_name: ReviewCommand, command: :review, description: "Create a review for a product using GPT-4"},
    {class_name: CatCommand, command: :cat, aliases: [:cats, :meow], description: "Meow?"},
    {class_name: DisclaimerCommand, command: :disclaimer, description: "Generate fine print with GPT-4"},
    {class_name: InsultCommand, command: :insult, description: "Insult someone or something with GPT-4"},
    {class_name: ComplainCommand, command: :complain, description: "Complain about something with GPT-4"},
    {class_name: SongCommand, command: :song, aliases: [:sing], description: "Compose some lyrics with GPT-4"},
    {class_name: DefineCommand, command: :define, aliases: [:definition, :def], description: "Get the possibly correct definition of something with GPT-4"},
    {class_name: NewCommand, command: :new, description: "Make a new something with GPT-4"},
    {class_name: SummaryCommand, command: :summary, aliases: [:summarize, :summarise], description: "Summarise the day of conversation using GPT-4"},
    {class_name: AskCommand, command: :ask, aliases: [:perplexity, :question, :query], description: "Ask a question with Perplexity"}
  ].freeze

  attr_reader :bot

  def initialize(token:)
    @token = token
    @bot = Discordrb::Commands::CommandBot.new(
      token: token,
      prefix: COMMAND_PREFIXES,
      spaces_allowed: true,
      command_doesnt_exist_message: ->(event) {
        "Quack? What is up #{event.user.mention}?"
      },
      log_mode: (Global.config.discord.debug_log ? :debug : :normal)
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
          channel: event.channel&.name
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

    COMMANDS.sort_by { |c| c[:command].to_s }.each do |command_config|
      bot.command(command_config[:command], description: command_config[:description], aliases: command_config[:aliases] || []) do |event, *params|
        instance = command_config[:class_name].new(event: event, bot: bot, params: params)
        response = instance.respond
        if response.present?
          begin
            message = event.respond(response)
          rescue Discordrb::Errors::InvalidFormBody
            message = event.respond("Quack!! Error in error. Response looks too long!! #{response.first(1800)}")
          end
        end
        instance.after(message: message)
        nil
      end
    end

    bot.mention do |event|
      if event.message && !event.message.reply?
        Global.logger.info("mention #{event.author.name}: #{event.message.content}")
        event.channel.start_typing
        response = Learner.random_message(server: event.server&.name, channel: event.channel&.name, prevent_recent: true) || Quacker.quack
        sleep(0.6)
        event.respond(response)
      end
    end

    bot.message do |event|
      Recorder.record(event)
    end

    bot.message_edit do |event|
      Recorder.edit(event)
    end

    bot.message_delete do |event|
      Recorder.delete(event)
    end

    bot.message do |event|
      if event.channel.pm? && !COMMAND_PREFIXES.any? { |c| event.message.content.starts_with?(c) }
        Global.logger.info("pm #{event.author.name}: #{event.message.content}")
        event.respond(Quacker.quack)
      else # in a channel
        RESPONDERS.each do |responder_class|
          responder_class.new(event, bot: bot).then { |r| r.respond if r.permitted? }
        rescue => e
          Global.logger.error("#{responder_class} returned error #{e.message}")
          Global.logger.error(e)
          message = ":bangbang: Quack error in #{responder_class}: #{e.message}"
          event.respond(message)
        end
      end
    end

    Global.logger.info("Starting Duck")

    bot.run(true)

    WebDuck.run!
  end
end
