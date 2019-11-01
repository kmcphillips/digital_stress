# frozen_string_literal: true
class Datastore
  FILENAME = "chat.sqlite3"
  USERNAMES = {
    "dave" => [ "Dave" ],
    "eliot" => [ "Eliot" ],
    "patrick" => [ "P-DOG" ],
    "kevin" => [ "kmcphillips" ],
  }.freeze

  attr_reader :db

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
    @db.execute("select message from messages where username = ? order by timestamp asc", [username]).map { |r| r.first }
  end

  def dump_all
    USERNAMES.keys.each_with_object({}) { |username, result| result[username] = dump(username) }
  end

  def peek
    lines = []

    lines << "Totals:"
    @db.execute("select username, count(*) from messages group by username").each do |row|
      lines << "  #{row[0]}: #{row[1]}"
    end
    lines << ""
    lines << "Recent:"
    @db.execute("select username, message, timestamp from messages order by timestamp desc limit 10").reverse.each do |row|
      lines << "  #{row[0]} (#{Time.at(row[2])}): #{row[1]}"
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

  def parse_username(input)
    scrubbed_input = input.gsub(/#\d+$/, "").downcase

    USERNAMES.each do |username, matches|
      matches.each do |match|
        return username if match.downcase == scrubbed_input
      end
    end

    raise "Unkonwn username #{input}"
  end

  def parse_message(input)
    (input || "").gsub("\n", " ")
  end
end
