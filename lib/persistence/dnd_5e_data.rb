# frozen_string_literal: true
module Dnd5eData
  extend self

  DB_FILE = Global.root.join("data/dnd5e.sqlite3")

  def load
    return false if defined?(@loaded)

    @db = Sequel.sqlite(DB_FILE.to_s)

    spells = @db[:spells].all.map { |s| Spell.new(s) }
    @spell_matcher = FuzzyMatch.new(spells, read: :name)

    @loaded = true
  end

  def find_spell(search)
    @spell_matcher.find(search)
  end

  def loader
    @loader ||= Dnd5eData::Loader.new(DB_FILE)
  end

  class Spell
    attr_reader :name, :slug, :description, :casting_time, :source, :url, :components, :duration, :range, :spell_lists, :level, :school

    def initialize(attributes)
      @name = attributes[:name]
      @slug = attributes[:slug]
      @description = attributes[:description]
      @casting_time = attributes[:casting_time]
      @source = attributes[:source]
      @url = attributes[:url]
      @components = attributes[:components]
      @duration = attributes[:duration]
      @range = attributes[:range]
      @spell_lists = attributes[:spell_lists]
      @level = attributes[:level]
      @school = attributes[:school]
    end

    def to_discord_s
      [
        "**#{ name }**",
        url,
        "> #{ level } (#{ school })",
        "> Casting time: _#{ casting_time }_",
        "> Components: _#{ components }_",
        "> Duration: _#{ duration }_",
        "> Range: _#{ range }_",
        "> \n> #{ description.gsub("\n", "\n> \n> ") }",
      ].join("\n")
    end
  end

  class Loader
    attr_reader :db_file

    def initialize(db_file)
      @db_file = db_file
      @db = Sequel.sqlite(db_file.to_s)
    end

    def reset!
      FileUtils.rm(db_file) if File.exist?(db_file)
      FileUtils.touch(db_file)

      @db = Sequel.sqlite(db_file.to_s)

      @db.create_table :spells do
        primary_key :id
        String :name
        String :slug
        String :description
        String :casting_time
        String :source
        String :url
        String :components
        String :duration
        String :range
        String :spell_lists
        String :level
        String :school
        index :slug
        index :name
      end
    end

    def add_spell(spell)
      @db[:spells].insert(spell)
    end
  end
end
