# frozen_string_literal: true
class Datastore
  FILENAME = "chat.sqlite3"

  def initialize
    @db = SQLite3::Database.new(File.join(File.dirname(__FILE__), FILENAME))
  end

  def setup!
    @db.execute("create table messages ( timestamp integer, username varchar(255), message text );")
  end

  def append(username, message, time=nil)
    input = [parse_timestamp(time), parse_username(username), parse_message(message)]
    @db.execute("insert into messages ( timestamp, username, message ) values ( ?, ?, ? )", input)
  end

  def dump(username)
    # Time.at()
  end

  private

  def parse_timestamp(input)
    case input
    when NilClass
      Time.now.to_i
    when Time
      input.to_i
    when Integer
      input
    else
      raise "Unknown time #{input}"
    end
  end

  def parse_username(input)
    case input.gsub(/#\d+$/, "")
    when "Dave" then "dave"
    when "Eliot" then "eliot"
    when "P-DOG" then "patrick"
    when "kmcphillips" then "kevin"
    else
      raise "Unkonwn username #{input}"
    end
  end

  def parse_message(input)
    (input || "").gsub("\n", " ")
  end
end
