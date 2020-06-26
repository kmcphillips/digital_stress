# frozen_string_literal: true
class Datastore
  attr_reader :db

  def initialize(path)
    @db = SQLite3::Database.new(path)
  end

  def append(username:, user_id:, message:, server:, channel:, time:nil)
    input = [parse_timestamp(time), user_id, username, parse_message(message), server, channel]
    @db.execute("INSERT INTO messages ( timestamp, user_id, username, message, server, channel ) VALUES ( ?, ?, ?, ?, ?, ? )", input)
  end

  def learn(user_id:, message_id:, message:, server:, channel:, time:nil)
    input = [parse_timestamp(time), user_id, message_id, parse_message(message), server, channel]
    @db.execute("INSERT INTO learned ( timestamp, user_id, message_id, message, server, channel ) VALUES ( ?, ?, ?, ?, ?, ? )", input)
  end

  def random_learned(user_id: nil, server:)
    result = if user_id
      @db.execute("SELECT message, user_id FROM learned WHERE server = ? AND user_id = ? ORDER BY RANDOM() LIMIT 1", [server, user_id])
    else
      @db.execute("SELECT message, user_id FROM learned WHERE server = ? ORDER BY RANDOM() LIMIT 1", [server])
    end

    result.to_a.first
  end

  def learned(user_id: nil, server:)
    result = if user_id
      @db.execute("SELECT id, message, user_id, message_id FROM learned WHERE server = ? AND user_id = ?", [server, user_id])
    else
      @db.execute("SELECT id, message, user_id, message_id FROM learned WHERE server = ?", [server])
    end

    result.to_a
  end

  def find_learned(id)
    @db.execute("SELECT message FROM learned WHERE id = ?", [id]).to_a.first.first
  end

  def update_learned(id, message)
    @db.execute("UPDATE learned SET message = ? WHERE id = ?", [message, id])
  end

  def delete_learned(id)
    @db.execute("DELETE FROM learned WHERE id = ?", [id])
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
