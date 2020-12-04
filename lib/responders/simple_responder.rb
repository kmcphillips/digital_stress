# frozen_string_literal: true
class SimpleResponder < BaseResponder
  def respond
    respond_match(text, /hang(ing)?.?in.?there/i, "https://i.imgur.com/1FlykyH.jpg")
    react_match(text, /\bheat\b/i, "🔥")
    react_match(text, /\bhwat\b/i, "🔥")
    respond_match(text, /\bheat\b/i, "don't be hwat...", chance: 0.08)
    react_match(text, /tight/i, "🤏")
    react_match(text, /(noot|neet)/i, "👢")
    react_match(text, /(good|great|nice|best) duck/i, "❤️")
    respond_match(text, /several people are typing/i, "https://i.kym-cdn.com/photos/images/newsfeed/001/249/060/9c3.gif")
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
