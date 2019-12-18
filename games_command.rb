# frozen_string_literal: true
class GamesCommand < BaseSubcommand
  def subcommands
    {
      list: "What games are on the docket?",
      add: "Add a game by name and with a Steam URL",
      retire: "Retire a game by name or Steam URL",
    }.freeze
  end

  private

  def list
    # TODO
  end

  def add
    # TODO
  end

  def retire
    # TODO
  end
end
