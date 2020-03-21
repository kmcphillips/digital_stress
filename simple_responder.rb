# frozen_string_literal: true
class SimpleResponder < BaseResponder
  def respond
    text = event.message.content || ""

    # event.channel.start_typing
    # event.message.react(emoji)
    # event.respond(message)

    if text.downcase.match?(/hang.?in.?there/)
      event.respond("https://i.imgur.com/1FlykyH.jpg")
    end

    if text.downcase.match?(/heat/i)
      if rand < 0.08
        event.respond("don't be hwat...")
      end
      event.message.react("🔥")
    end

    if text.downcase.match?(/noot/i)
      event.message.react("👢")
    end
  end
end
