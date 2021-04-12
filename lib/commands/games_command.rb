# frozen_string_literal: true
class GamesCommand < BaseSubcommand
  def subcommands
    {
      list: "What games should we play?",
      add: "Add a game by name and with a Steam URL",
      retire: "Retire a game by name or Steam URL",
    }.freeze
  end

  def channels
    [
      "mandatemandate#general",
      "duck-bot-test#testing",
    ]
  end

  private

  def list
    ":man_technologist: This doesn't work yet."
  end

  def add
    ":man_technologist: This doesn't work yet."
  end

  def retire
    ":man_technologist: This doesn't work yet."
  end
end
