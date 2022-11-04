# frozen_string_literal: true

require_relative "base"

def usage
  puts "USAGE: bundle exec ruby load_absurdity_chats.rb user_id username server path_to_file"
  exit 1
end

user_id = ARGV[0]
username = ARGV[1]
server = ARGV[2]
path = ARGV[3]

usage if user_id.blank? || username.blank? || server.blank?
usage if user_id.to_i <= 0
usage unless File.exist?(path)

lines = File.readlines(path)

usage unless lines.length > 0

puts "Loading absurdity chats...
  user_id: #{ user_id }
  username: #{ username }
  server: #{ server }
  file: #{ path } with #{ lines.length } lines

Press enter to continue or ctrl-c to cancel"

response = $stdin.gets

puts "Loading #{ lines.length } chats..."

lines.each do |line|
  AbsurdityChatStore.create(user_id: user_id, username: username, server: server, message: line.strip)
end

puts "Done"
