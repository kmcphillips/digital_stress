# frozen_string_literal: true

class SimpleResponder < BaseResponder
  include ResponderMatcher

  MANDATE_CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#wives",
    "mandatemandate#mandate_totality",
    "mandatemandate#dnd",
    "duck-bot-test#testing"
  ].freeze

  def respond
    react_match(/\bheat\b/i, "🔥")
    react_match(/\bhwat\b/i, "🔥")
    react_match(/tight/i, "🤏")
    react_match(/(italy|italian)/i, "🤌")
    react_match(/(noot|neet)/i, "👢")
    react_match(/(good|great|nice|best) duck/i, "❤️")

    respond_match(/hang(ing)?.?in.?there/i, responder_image("hang_in_there.jpg"))
    respond_match(/\bheat\b/i, "don't be hwat...", chance: 0.08)
    respond_match(/several people are typing/i, responder_image("several_people_are_typing.gif"))
    respond_match(/\Afuck(\Z| .)/i, "You talking to me?", channels: MANDATE_CHANNELS, chance: 0.3)
    respond_match(/\Adick(\Z| .)/i, "Call me Richard", channels: MANDATE_CHANNELS)
    respond_match(/pickle.?surprise/i, responder_image("pickle_surprise.png"))
    respond_match(/yes to recover/i, responder_image("say_yes_to_recovery.png"))
  end
end
