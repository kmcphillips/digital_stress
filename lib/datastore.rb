# frozen_string_literal: true
class Datastore
  FILE_PATH = File.join(File.dirname(__FILE__), "..", "chat.sqlite3")

  attr_reader :db

  def initialize
    @db = SQLite3::Database.new(FILE_PATH)
  end

  def setup!
    @db.execute("CREATE TABLE messages ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, user_id INTEGER, username VARCHAR(255), message TEXT, server VARCHAR(255), channel VARCHAR(255) );")
    @db.execute("CREATE TABLE learned ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, user_id INTEGER, message TEXT, server VARCHAR(255), channel VARCHAR(255) );")
    @db.execute("CREATE TABLE alchemy ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, server VARCHAR(255), kevin INTEGER NOT NULL DEFAULT 0, eliot INTEGER NOT NULL DEFAULT 0, dave INTEGER NOT NULL DEFAULT 0, patrick INTEGER NOT NULL DEFAULT 0 );")
  end

  def migrate
    @db.execute("CREATE TABLE alchemy ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp INTEGER, server VARCHAR(255), kevin INTEGER NOT NULL DEFAULT 0, eliot INTEGER NOT NULL DEFAULT 0, dave INTEGER NOT NULL DEFAULT 0, patrick INTEGER NOT NULL DEFAULT 0 );")
  end

  def append(username:, user_id:, message:, server:, channel:, time:nil)
    input = [parse_timestamp(time), user_id, username, parse_message(message), server, channel]
    @db.execute("INSERT INTO messages ( timestamp, user_id, username, message, server, channel ) VALUES ( ?, ?, ?, ?, ?, ? )", input)
  end

  def learn(user_id:, message:, server:, channel:, time:nil)
    input = [parse_timestamp(time), user_id, parse_message(message), server, channel]
    @db.execute("INSERT INTO learned ( timestamp, user_id, message, server, channel ) VALUES ( ?, ?, ?, ?, ? )", input)
  end

  def learned(user_id: nil, server:)
    result = if user_id
      @db.execute("SELECT message, user_id FROM learned WHERE server = ? AND user_id = ? ORDER BY RANDOM() LIMIT 1", [server, user_id])
    else
      @db.execute("SELECT message, user_id FROM learned WHERE server = ? ORDER BY RANDOM() LIMIT 1", [server])
    end

    result.to_a.first
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
    @db.execute("SELECT username, user_id, message, timestamp, server, channel FROM messages ORDER BY timestamp DESC LIMIT 1").first
  end

  def peek
    lines = []

    lines << "Totals:"
    @db.execute("SELECT username, count(*) FROM messages GROUP BY username").each do |row|
      lines << "  #{row[0]}: #{row[1]}"
    end
    lines << ""
    lines << "Recent:"
    @db.execute("SELECT id, username, message, timestamp, server, channel FROM messages ORDER BY timestamp DESC LIMIT 10").reverse.each do |row|
      lines << "  #{row[1]} (#{Time.at(row[3])} ##{row[0]}) #{ row[4] }##{ row[5] }: #{row[2]}"
    end
    lines << ""
    @db.execute("SELECT count(*) FROM learned").each do |row|
      lines << "Learned: #{row[0]}"
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
