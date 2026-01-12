# frozen_string_literal: true

class AlchemyCommand < BaseCommand
  def channels
    [
      "mandatemandate#general",
      "mandatemandate#dnd",
      "duck-bot-test#testing"
    ]
  end

  def response
    party = AlchemyResponder::Party.new(server: server, channel: channel)

    if party.size == 0
      "Are we playing games tonight??"
    elsif party.size == 4
      "✅ ✅ ✅ ✅ Everyone accounted for tonight."
    else
      present = []
      missing = []

      party.elements.each do |element|
        name = party.name_for(element)
        if party.present?(element)
          present << name
        else
          missing << name
        end
      end

      present.shuffle!
      missing.shuffle!

      "✅ #{present.join(" ")} ... But no word yet from #{missing.to_sentence}"
    end
  end

  private
end
