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
    entries = [
      GameRecord.new(name: "Satisfactory", state: "Fresh", url: "https://store.steampowered.com/app/526870/Satisfactory"),
      GameRecord.new(name: "Duck Game", state: "Permanent"),
      GameRecord.new(name: "Factorio", state: "Replay"),
      GameRecord.new(name: "Golf", state: "Maybe"),
      GameRecord.new(name: "Golf 2", state: "Retired"),
      GameRecord.new(name: "Borderlands 3", state: "Retired"),
    ]

    table = Tabulo::Table.new(entries) do |t|
      t.add_column("Game") { |entry, index| entry.name }
      t.add_column("What's up?") { |entry, index| entry.state }
      t.add_column("Steam") { |entry, index| entry.url }
    end
    table.pack

    format_table(table)
  end

  def add
    ":man_technologist: This doesn't work yet."
  end

  def retire
    ":man_technologist: This doesn't work yet."
  end

  def format_table(str)
    "```\n#{ str.to_s }```"
  end

  class GameRecord
    attr_reader :name, :state, :url

    def initialize(name:, state:, url: nil)
      @name = name
      @state = state
      @url = url
    end
  end
end
