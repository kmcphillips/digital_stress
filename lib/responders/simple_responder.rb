# frozen_string_literal: true
class SimpleResponder < BaseResponder
  include ResponderMatcher

  def respond
    react_match(/\bheat\b/i, "🔥")
    react_match(/\bhwat\b/i, "🔥")
    react_match(/tight/i, "🤏")
    react_match(/(noot|neet)/i, "👢")
    react_match(/(good|great|nice|best) duck/i, "❤️")
    react_match(/quigital/i, "quigital", channels: [ "mandatemandate#general", "duck-bot-test#testing" ])

    respond_match(/hang(ing)?.?in.?there/i, "https://i.imgur.com/1FlykyH.jpg")
    respond_match(/\bheat\b/i, "don't be hwat...", chance: 0.08)
    respond_match(/several people are typing/i, "https://i.kym-cdn.com/photos/images/newsfeed/001/249/060/9c3.gif")
    respond_match(/safe/i, "https://i.imgur.com/1WReL2h.jpg", chance: 0.2)
    respond_match(/brain injur|concussion/i, "https://media3.giphy.com/media/NhXhI7kHCwxRC/giphy.gif", chance: 0.3)
  end
end
