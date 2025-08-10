# frozen_string_literal: true

require_relative "../lib/base"

loader = Dnd2024Data.loader
parser = Dnd2024Parser.new
count = 0

puts "Resetting database"
loader.reset!

puts "Loading spells"
spell_urls = parser.fetch_urls_from_index

spell_urls.each do |spell_url|
  spell = parser.fetch_spell_from_url(spell_url)
  loader.add_spell(spell)
  count += 1
  print "."
end

puts ""
puts "Added #{count} spells"
