# frozen_string_literal: true
class SimpleResponder < BaseResponder
  include ResponderMatcher

  MANDATE_CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#wives",
    "mandatemandate#mandate_totality",
    "mandatemandate#dnd",
    "duck-bot-test#testing",
  ].freeze

  def respond
    react_match(/\bheat\b/i, "🔥")
    react_match(/\bhwat\b/i, "🔥")
    react_match(/tight/i, "🤏")
    react_match(/(italy|italian)/i, "🤌")
    react_match(/(noot|neet)/i, "👢")
    react_match(/(good|great|nice|best) duck/i, "❤️")

    respond_match(/hang(ing)?.?in.?there/i, "https://i.imgur.com/1FlykyH.jpg")
    respond_match(/\bheat\b/i, "don't be hwat...", chance: 0.08)
    respond_match(/several people are typing/i, "https://i.kym-cdn.com/photos/images/newsfeed/001/249/060/9c3.gif")
    respond_match(/safe/i, "https://i.imgur.com/1WReL2h.jpg", channels: MANDATE_CHANNELS, chance: 0.02)
    respond_match(/\Afuck(\Z| .)/i, "You talking to me?", channels: MANDATE_CHANNELS, chance: 0.3)
    respond_match(/\Adick(\Z| .)/i, "Call me Richard", channels: MANDATE_CHANNELS)
    respond_match(/pickle.?surprise/i, "https://cdn.discordapp.com/attachments/250717538063745024/1054566918536843274/Eliot_ultimate_pickle_surprise_8bf66f6a-b3a1-441d-a530-241e7c37d8b5.png")
  end
end
