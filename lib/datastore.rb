# frozen_string_literal: true
class Datastore
  attr_reader :db

  def initialize(path)
    @db = SQLite3::Database.new(path)
  end

  def append(username:, user_id:, message:, server:, channel:, time:nil)
    input = [Formatter.parse_timestamp(time), user_id, username, Formatter.compact_multiline(message), server, channel]
    @db.execute("INSERT INTO messages ( timestamp, user_id, username, message, server, channel ) VALUES ( ?, ?, ?, ?, ?, ? )", input)
  end

  def dump(username)
    @db.execute("SELECT message FROM messages WHERE username = ? ORDER BY timestamp ASC", [username]).map { |r| r.first }
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
end
