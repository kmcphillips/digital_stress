# frozen_string_literal: true

require_relative "../lib/base"
require "csv"
require "set"

message_reject_patterns = [
  /<@!?[0-9]+>/,
  /\Aduck /i
]

def scrub_discord_formatting(str)
  str
    .strip
    .gsub("<@!#{User.dave.id}>", User.dave.mandate_display_name)
    .gsub("<@!#{User.eliot.id}>", User.eliot.mandate_display_name)
    .gsub("<@!#{User.kevin.id}>", User.kevin.mandate_display_name)
    .gsub("<@!#{User.patrick.id}>", User.patrick.mandate_display_name)
    .gsub("<@#{User.dave.id}>", User.dave.mandate_display_name)
    .gsub("<@#{User.eliot.id}>", User.eliot.mandate_display_name)
    .gsub("<@#{User.kevin.id}>", User.kevin.mandate_display_name)
    .gsub("<@#{User.patrick.id}>", User.patrick.mandate_display_name)
    .gsub("@P-DOG", "Patrick")
    .gsub("@Eliot", "Eliot")
    .gsub("@kmcphillips", "Kevin")
    .gsub("@Dave", "Dave")
end

row_count = 0

# export chats
records = Global.db[:messages]
  .where(server: "mandatemandate", channel: "general")
  .order(Sequel.lit("RANDOM()"))

puts "Processing #{records.count} records..."

[User.kevin, User.dave, User.patrick, User.eliot].each do |user|
  text_set = Set.new
  row_count = 0
  filename = "openai_export_#{user.mandate_name}.csv"

  puts "  Writing user #{user.mandate_display_name} to #{filename}"
  records = Global.db[:messages]
    .where(server: "mandatemandate", channel: "general", user_id: user.id)
    .order(Sequel.lit("RAND()"))
    .limit(1100)

  CSV.open(filename, "w") do |csv|
    csv << ["prompt", "completion"]

    records.each do |record|
      break if row_count == 1000
      text = scrub_discord_formatting(record[:message])

      if !text_set.include?(text) && message_reject_patterns.none? { |pattern| text.match?(pattern) }
        csv << ["", " #{text} ###"]
        text_set.add(text)
        row_count += 1
      end
    end
  end

  puts "  Done. #{row_count} rows written."
end

# # export questions
# records = Global.db[:messages]
#   .where(server: "mandatemandate", channel: "general")
#   .order(Sequel.desc(:timestamp))

# puts "Processing #{ records.count } records..."

# CSV.open("openai_export.csv", "w") do |csv|
#   csv << ["prompt", "completion"]

#   previous_record = nil
#   records.each do |record|
#     if !previous_record
#       previous_record = record
#       next
#     end

#     if record[:message].ends_with?("?")
#       previous_user = User.from_id(previous_record[:user_id], server: "mandatemandate")&.mandate_display_name
#       user = User.from_id(record[:user_id], server: "mandatemandate")&.mandate_display_name

#       if previous_user && user && previous_user != user
#         response = "#{ previous_user }: #{ previous_record[:message] }"
#         prompt = "#{ user }: #{ record[:message] }"

#         pair = [prompt, response].map { |str| scrub_discord_formatting(str) }

#         if message_reject_patterns.none? { |pattern| pair[0].match?(pattern) || pair[1].match?(pattern) }
#           csv << pair
#           print "."
#           row_count += 1
#           previous_record = nil
#         end
#       end
#     end

#     previous_record = record if previous_record
#   end
# end

# puts ""
# puts "Done. #{ row_count } rows written."
