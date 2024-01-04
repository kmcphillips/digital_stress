# frozen_string_literal: true
require_relative "../lib/base"
require "csv"

source_filename = "openai_export_culled.csv"

NAME_REGEX = /\A([A-Za-z]{4,7}):/

puts "Opening #{ source_filename }..."
source = CSV.read(source_filename, headers: true)

output = {
  dave: [],
  eliot: [],
  kevin: [],
  patrick: [],
}

puts "Processing #{ source.count } records..."
source.each do |row|
  prompt = row["prompt"]
  completion = row["completion"]
  raise "Prompt is blank" if prompt.blank?
  raise "Completion is blank" if completion.blank?
  raise "Found a prompt with ending sequence: #{ prompt }" if prompt.include?("###")
  raise "Found a completion with ending sequence: #{ completion }" if completion.include?("###")
  raise "Prompt does not start with a name: #{ prompt }" unless prompt.strip.match?(NAME_REGEX)
  raise "Completion does not start with a name: #{ completion }" unless completion.strip.match?(NAME_REGEX)
  raise "Prompt does not end with a question mark: #{ prompt }" unless prompt.strip.ends_with?("?")

  output_prompt = prompt.strip.sub(NAME_REGEX, "").strip
  name = completion.match(NAME_REGEX)[1]
  name_key = name.downcase.to_sym
  raise "Found a completion with an unknown name: #{ name_key }" unless output[name_key]

  output[name_key] << [output_prompt, completion.strip.sub(NAME_REGEX, "").strip]
  print "."
end

puts ""
output.each do |name_key, rows|
  output_filename = "openai_export_formatted_#{ name_key }.csv"
  puts "Writing #{ rows.count } rows to #{ output_filename }"
  CSV.open(output_filename, "w") do |csv|
    csv << ["prompt", "completion"]
    rows.each do |prompt, completion|
      prompt = "#{ prompt.strip }\n\n###\n\n"
      completion = " #{ completion.strip } ###"
      csv << [prompt, completion]
    end
  end
end
puts "Done."

# output_filename = "openai_export_formatted.csv"
# row_count = 0
# CSV.open(output_filename, "w") do |csv|
#   csv << ["prompt", "completion"]
#   source.each do |prompt, completion|
#     raise "Found a prompt with ending sequence" if prompt.include?("###")
#     raise "Found a completion with ending sequence" if completion.include?("###")
#     prompt = "#{ prompt } \n\n###\n\n"
#     completion = " #{ completion } ###"
#     csv << [prompt, completion]
#     row_count += 1
#   end
# end
# puts "Done. #{ row_count } rows written to #{ output_filename }."
