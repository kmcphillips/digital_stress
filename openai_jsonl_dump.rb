# frozen_string_literal: true
require_relative "base"

filename = "mandatemandate_openai.jsonl"
filepath = Global.root.join(filename)
count = 0

File.open(filepath, "w") do |file|
  Global.db[:messages].where(server: "mandatemandate", channel: "general").order(Sequel.asc(:timestamp)).each do |row|
    name = User::USERS.dig("mandatemandate", row[:user_id], :name)
    next unless name
    message = row[:message]
    file.write("#{ { text: message, label: name }.to_json }\n")
  end

  count += 1
end

puts "Wrote #{ count } lines to #{ filepath }"
puts "To upload:\n  curl https://api.openai.com/v1/files -H \"Authorization: Bearer #{ Global.openai.access_token }\" -F purpose=\"classification\" -F file=\"@#{ filename }\""
