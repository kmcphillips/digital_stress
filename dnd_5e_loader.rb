# frozen_string_literal: true
require_relative "base"

loader = Dnd5eData.loader
loader.reset!

count = 0

puts "Reset database"
puts "Loading spells"

spells_html = HTTParty.get("http://dnd5e.wikidot.com/spells")
spells_doc = Nokogiri.HTML5(spells_html)
spell_urls = []

spells_doc.css("div.list-pages-box table.wiki-content-table").each do |table|
  links = table.css("a")
  links.each do |link|
    spell_urls << {
      url: "http://dnd5e.wikidot.com#{ link.attributes["href"].value }",
      name: link.children.first.text,
      slug: slug = link.attributes["href"].value.gsub("/spell:", ""),
    }
  end
end

spell_urls.each do |spell_url|
  spell_html = HTTParty.get(spell_url[:url])
  raise "#{ spell_html } was not success" unless spell_html.success?
  spell_doc = Nokogiri.HTML5(spell_html)

  lines = spell_doc.css("#page-content p").map{ |p| p.text }.join("\n").split("\n")
  # TODO: need ul/li

  spell = {
    name: spell_url[:name],
    url: spell_url[:url],
    slug: spell_url[:slug],
  }

  spell[:description] = lines.select do |line|
    if line.start_with?("Casting Time: ")
      spell[:casting_time] = line.gsub("Casting Time: ", "")
      false
    elsif line.start_with?("Source: ")
      spell[:source] = line.gsub("Source: ", "")
      false
    elsif line.start_with?("Components: ")
      spell[:components] = line.gsub("Components: ", "")
      false
    elsif line.start_with?("Duration: ")
      spell[:duration] = line.gsub("Duration: ", "")
      false
    elsif line.start_with?("Range: ")
      spell[:range] = line.gsub("Range: ", "")
      false
    elsif line.start_with?("Spell Lists. ")
      spell[:spell_lists] = line.gsub("Spell Lists. ", "")
      false
    elsif line.start_with?(/[\d]/) || line.downcase.start_with?("cantrip")
      tokens = line.split(" ", 2)
      spell[:level] = tokens[0]
      spell[:school] = tokens[1]
      false
    elsif line.end_with?("cantrip")
      spell[:level] = "Cantrip"
      spell[:school] = line.gsub(" cantrip", "")
      false
    else
      true
    end
  end.join("\n")

  loader.add_spell(spell)

  count += 1
  print "."
end

puts ""
puts "Added #{ count } spells"
