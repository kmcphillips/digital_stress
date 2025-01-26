# frozen_string_literal: true

class Dnd5eParser
  ROOT_URL = "http://dnd5e.wikidot.com"

  def fetch_urls_from_index
    spell_urls = []

    spells_html = HTTParty.get("#{ROOT_URL}/spells")
    raise "#{spells_html} was not success" unless spells_html.success?
    spells_doc = Nokogiri.HTML5(spells_html)

    spells_doc.css("div.list-pages-box table.wiki-content-table").each do |table|
      links = table.css("a")
      links.each do |link|
        spell_urls << {
          url: "#{ROOT_URL}#{link.attributes["href"].value}",
          name: link.children.first.text,
          slug: link.attributes["href"].value.gsub("/spell:", "")
        }
      end
    end

    spell_urls
  end

  def fetch_spell_from_url(spell_url)
    spell_html = HTTParty.get(spell_url[:url])
    raise "#{spell_html} was not success" unless spell_html.success?
    spell_doc = Nokogiri.HTML5(spell_html)

    lines = spell_doc.css("#page-content p, #page-content ul, #page-content table").map do |tag|
      if tag.name == "p"
        tag.text
      elsif tag.name == "ul"
        tag.css("li").map { |li| "* #{li.text}" }
      elsif tag.name == "table"
        "[table]"
      else
        raise "unknown tag #{tag}"
      end
    end.flatten.join("\n").split("\n")

    unknown_tags = spell_doc.css("#page-content").children.map(&:name).uniq - ["text", "div", "p", "ul", "table"]
    if unknown_tags.any?
      raise "Unknown tag encountered: #{unknown_tags} in #{spell_url}"
    end

    spell = {
      name: spell_url[:name],
      url: spell_url[:url],
      slug: spell_url[:slug]
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

    spell
  end
end
