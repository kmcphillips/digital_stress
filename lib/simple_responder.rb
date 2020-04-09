# frozen_string_literal: true
class SimpleResponder < BaseResponder
  def respond
    text = event.message.content || ""

    # event.channel.start_typing
    # event.message.react(emoji)
    # event.respond(message

    if text.match?(/hang.?in.?there/i)
      event.respond("https://i.imgur.com/1FlykyH.jpg")
    end

    if text.match?(/heat/i)
      if rand < 0.08
        event.respond("don't be hwat...")
      end
      event.message.react("🔥")
    end

    if text.match?(/tight/i)
      event.message.react("🤏")
    end

    if text.match?(/noot/i)
      event.message.react("👢")
    end
  end
end
