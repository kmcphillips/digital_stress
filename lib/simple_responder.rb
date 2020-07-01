# frozen_string_literal: true
class SimpleResponder < BaseResponder
  def respond
    respond_match(text, /hang.?in.?there/i, "https://i.imgur.com/1FlykyH.jpg")
    react_match(text, /\bheat\b/i, "🔥")
    react_match(text, /\bhwat\b/i, "🔥")
    respond_match(text, /\bheat\b/i, "don't be hwat...", chance: 0.08)
    react_match(text, /tight/i, "🤏")
    react_match(text, /(noot|neet)/i, "👢")
    react_match(text, /(good|great|nice|best) duck/i, "❤️")
  end

  private

  def respond_match(text, regex, reply_message, chance: nil)
    if text.match?(regex) && (!chance || rand < chance)
      event.respond(reply_message)
    end
  end

  def react_match(text, regex, emoji, chance: nil)
    if text.match?(regex) && (!chance || rand < chance)
      event.message.react(emoji)
    end
  end
end
