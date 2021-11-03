# frozen_string_literal: true
module Dnd5eData
  extend self

  DB_FILE = Global.root.join("dnd5e.sqlite3")

  def load
    return false if defined?(@loaded)

    @db = Sequel.sqlite(DB_FILE.to_s)

    @loaded = true
  end

  def loader
    @loader ||= Dnd5eData::Loader.new(DB_FILE)
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
