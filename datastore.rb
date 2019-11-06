# frozen_string_literal: true
class Datastore
  FILENAME = "chat.sqlite3"

  attr_reader :db

  def initialize
    @db = SQLite3::Database.new(File.join(File.dirname(__FILE__), FILENAME))
  end

  def setup!
    @db.execute("CREATE TABLE messages ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, user_id INTEGER, username VARCHAR(255), message TEXT );")
  end

  def append(username:, user_id:, message:, time:nil)
    input = [parse_timestamp(time), user_id, username, parse_message(message)]
    @db.execute("INSERT INTO messages ( timestamp, user_id, username, message ) VALUES ( ?, ?, ?, ? )", input)
  end

  def dump(username)
    @db.execute("SELECT message FROM messages WHERE username = ? ORDER BY timestamp ASC", [username]).map { |r| r.first }
  end

  def dump_all
    USERNAMES.keys.each_with_object({}) { |username, result| result[username] = dump(username) }
  end

  def counts
    @db.execute("SELECT DISTINCT username, user_id, COUNT(*) FROM messages GROUP BY username ORDER BY username ASC")
  end

  def last
    @db.execute("SELECT username, user_id, message, timestamp FROM messages ORDER BY timestamp DESC LIMIT 1").first
  end

  def peek
    lines = []

    lines << "Totals:"
    @db.execute("SELECT username, count(*) FROM messages GROUP BY username").each do |row|
      lines << "  #{row[0]}: #{row[1]}"
    end
    lines << ""
    lines << "Recent:"
    @db.execute("SELECT id, username, message, timestamp FROM messages ORDER BY timestamp DESC LIMIT 10").reverse.each do |row|
      lines << "  #{row[1]} (#{Time.at(row[3])} ##{row[0]}): #{row[2]}"
    end

    lines.join("\n")
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

  def parse_message(input)
    (input || "").gsub("\n", " ")
  end
end
