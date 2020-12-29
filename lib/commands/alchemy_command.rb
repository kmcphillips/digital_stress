# frozen_string_literal: true
class AlchemyCommand < BaseCommand
  def channels
    [
      "mandatemandate#general",
      "duck-bot-test#testing",
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

      if party.present?(:earth)
        present << "🏔"
      else
        missing << User.eliot
      end

      if party.present?(:fire)
        present << "🔥"
      else
        missing << User.kevin
      end

      if party.present?(:water)
        present << "🌊"
      else
        missing << User.dave
      end

      if party.present?(:wind)
        present << "🌬️"
      else
        missing << User.patrick
      end

      present.shuffle!
      missing.shuffle!

      "✅ #{ present.join(" ") } ... But no word yet from #{ missing.map(&:mention).to_sentence }"
    end
  end

  private

end
