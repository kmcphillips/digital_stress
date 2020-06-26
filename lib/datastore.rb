# frozen_string_literal: true
class Datastore
  attr_reader :db

  def initialize(path)
    @db = SQLite3::Database.new(path)
  end
end
