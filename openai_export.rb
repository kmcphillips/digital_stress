# frozen_string_literal: true
require_relative "base"
require "csv"

records = Global.db[:messages]
  .where(server: "mandatemandate", channel: "general")
  .order(Sequel.desc(:timestamp))

puts "Processing #{ records.count } records..."

row_count = 0

message_reject_patterns = [
  /<\@\!?[0-9]+>/,
  /\Aduck /i,
]

CSV.open("openai_export.csv", "w") do |csv|
  csv << ["prompt", "completion"]

  previous_record = nil
  records.each do |record|
    if !previous_record
      previous_record = record
      next
    end

    if record[:message].ends_with?("?")
      previous_user = User.from_id(previous_record[:user_id], server: "mandatemandate")&.mandate_name_capitalized
      user = User.from_id(record[:user_id], server: "mandatemandate")&.mandate_name_capitalized

      if previous_user && user && previous_user != user
        response = "#{ previous_user }: #{ previous_record[:message] }"
        prompt = "#{ user }: #{ record[:message] }"

        pair = [prompt, response].map do |str|
          str
            .gsub("<@!#{ User.dave.id }>", User.dave.mandate_name_capitalized)
            .gsub("<@!#{ User.eliot.id }>", User.eliot.mandate_name_capitalized)
            .gsub("<@!#{ User.kevin.id }>", User.kevin.mandate_name_capitalized)
            .gsub("<@!#{ User.patrick.id }>", User.patrick.mandate_name_capitalized)
            .gsub("<@#{ User.dave.id }>", User.dave.mandate_name_capitalized)
            .gsub("<@#{ User.eliot.id }>", User.eliot.mandate_name_capitalized)
            .gsub("<@#{ User.kevin.id }>", User.kevin.mandate_name_capitalized)
            .gsub("<@#{ User.patrick.id }>", User.patrick.mandate_name_capitalized)
            .gsub("@P-DOG", "Patrick")
            .gsub("@Eliot", "Eliot")
            .gsub("@kmcphillips", "Kevin")
            .gsub("@Dave", "Dave")
        end

        if message_reject_patterns.none? { |pattern| pair[0].match?(pattern) || pair[1].match?(pattern) }
          csv << pair
          print "."
          row_count += 1
          previous_record = nil
        end
      end
    end

    previous_record = record if previous_record
  end
end

puts ""
puts "Done. #{ row_count } rows written."
