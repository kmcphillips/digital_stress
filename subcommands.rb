# frozen_string_literal: true
class BaseCommand
  attr_reader :params

  def initialize(event:, bot:, params:, datastore:)
    @datastore = datastore
    @bot = bot
    @params = params
    @event = event
  end

  def respond
    Log.info("command.#{ @event.command.name }(#{ params })")
    @event.channel.start_typing
    begin
      message = response
      message = message.join("\n") if message.is_a?(Array)
      Log.info("response: #{ message }")
    rescue => e
      Log.error("#{ self.class.name }#response returned error #{ e.message }")
      Log.error(e)
      message = ":bangbang: Quack error: #{ e.message }"
    end
    message
  end

  private

  def response
    raise NotImplementedError
  end
end

class BaseSubcommand < BaseCommand
  def subcommands
    raise NotImplementedError
  end

  private

  def response
    if subcommand && subcommand != "help" && subcommands.keys.map{|k| k.to_s.downcase}.include?(subcommand)
      send(params.first.to_s.downcase)
    else
      help
    end
  end

  def subcommand
    params.first.presence.to_s.downcase if params.first.present?
  end

  def subcommand_params
    if !@subcommand_params
      @subcommand_params = params.dup
      @subcommand_params.shift
    end
    @subcommand_params
  end

  def help
    ["**List of `#{ @event.command.name }` subcommands:**"] + subcommands.map{|k,v| "`#{ k }`: #{ v }" }
  end
end
