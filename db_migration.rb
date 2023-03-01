# frozen_string_literal: true
require_relative "base"

migration_url = ENV["DUCK_DB_MIGRATION_URL"]
raise "DUCK_DB_MIGRATION_URL not set" unless migration_url.present?

tmp_db_file = Global.root.join("tmp_db.sqlite3").to_s

File.open(tmp_db_file, "w") do |file|
  file.binmode
  HTTParty.get(migration_url, stream_body: true) do |fragment|
    file.write(fragment)
  end
end

puts "Connecting to MySQL #{ Global.config.db.url }"
mysql = Mysql.connect(Global.config.db.url)
puts "Connecting to SQLite #{ tmp_db_file }"
sqlite = Sequel.sqlite(tmp_db_file)

tables = {
  messages: true,
  learned: true,
  train_accidents: true,
  redis: true,
}

if tables[:messages]
  puts "Migrating messages..."

  source_count = sqlite[:messages].count
  puts "  Found #{ source_count } messages in sqlite"

  mysql.query("drop table if exists messages")
  mysql.query("create table messages (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    timestamp BIGINT,
    user_id BIGINT,
    username VARCHAR(255),
    message TEXT ,
    server VARCHAR(255),
    channel VARCHAR(255),
    message_id BIGINT
  ) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;")

  sqlite[:messages].order(:id).each do |source|
    begin
      statement = mysql.prepare('insert into messages (id, timestamp, user_id, username, message, server, channel, message_id) values (?,?,?,?,?,?,?,?)')
      statement.execute(source[:id], source[:timestamp], source[:user_id], source[:username], source[:message].to_s, source[:server], source[:channel], source[:message_id])
    rescue => e
      puts "Error in #{ source } #{ e.message }"
      raise e
    end
  end

  target_count = mysql.query('select count(*) from messages').fetch_row.first.to_i
  puts "  Migrated #{ target_count } messages to mysql"

  raise "Migration failed, source and target counts do not match" if target_count != source_count
else
  puts "Skipping messages"
end

if tables[:learned]
  puts "Migrating learned..."

  source_count = sqlite[:learned].count
  puts "  Found #{ source_count } learned in sqlite"

  mysql.query("drop table if exists learned")
  mysql.query("CREATE TABLE learned (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    timestamp BIGINT,
    user_id BIGINT,
    message TEXT,
    server VARCHAR(255),
    channel VARCHAR(255),
    message_id BIGINT
  ) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;")

  sqlite[:learned].order(:id).each do |source|
    begin
      statement = mysql.prepare('insert into learned (id, timestamp, user_id, message, server, channel, message_id) values (?,?,?,?,?,?,?)')
      statement.execute(source[:id], source[:timestamp], source[:user_id], source[:message].to_s, source[:server], source[:channel], source[:message_id])
    rescue => e
      puts "Error in #{ source } #{ e.message }"
      raise e
    end
  end

  target_count = mysql.query('select count(*) from learned').fetch_row.first.to_i
  puts "  Migrated #{ target_count } learned to mysql"

  raise "Migration failed, source and target counts do not match" if target_count != source_count
else
  puts "Skipping learned"
end

if tables[:train_accidents]
  puts "Migrating train_accidents..."

  source_count = sqlite[:train_accidents].count
  puts "  Found #{ source_count } train_accidents in sqlite"

  mysql.query("drop table if exists train_accidents")
  mysql.query("CREATE TABLE train_accidents (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    timestamp BIGINT,
    user_id BIGINT,
    server VARCHAR(255),
    channel VARCHAR(255)
  ) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;")

  sqlite[:train_accidents].order(:id).each do |source|
    begin
      statement = mysql.prepare('insert into train_accidents (id, timestamp, user_id, server, channel) values (?,?,?,?,?)')
      statement.execute(source[:id], source[:timestamp], source[:user_id], source[:server], source[:channel])
    rescue => e
      puts "Error in #{ source } #{ e.message }"
      raise e
    end
  end

  target_count = mysql.query('select count(*) from train_accidents').fetch_row.first.to_i
  puts "  Migrated #{ target_count } train_accidents to mysql"

  raise "Migration failed, source and target counts do not match" if target_count != source_count
else
  puts "Skipping train_accidents"
end

if tables[:redis]
  puts "Creating redis_0..."


  mysql.query("drop table if exists redis_0")
  mysql.query("CREATE TABLE redis_0 (
    `key` VARCHAR(255),
    value VARCHAR(255),
    timestamp BIGINT
  ) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;")
else
  puts "Skipping redis_0"
end

puts "Done"
