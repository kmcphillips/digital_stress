# frozen_string_literal: true

class BaseSubcommand < BaseCommand
  def subcommands
    raise NotImplementedError
  end

  private

  def response
    if subcommand && subcommand != "help" && subcommands.keys.map { |k| k.to_s.downcase }.include?(subcommand)
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

  def subcommand_query
    subcommand_params.join(" ")
  end

  def help
    ["**List of `#{@event.command.name}` subcommands:**"] + subcommands.map { |k, v| "`#{k}`: #{v}" }
  end
end
