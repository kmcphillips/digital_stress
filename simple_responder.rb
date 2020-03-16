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
  end
end
