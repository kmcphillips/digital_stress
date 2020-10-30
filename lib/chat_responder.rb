# frozen_string_literal: true
class ChatResponder < BaseResponder
  def respond
    return unless ChatAbsurdityRemberer::CHANNELS.include?("#{ event.server&.name }##{ event.channel&.name }")
    return unless remberer.enabled?

    remberer.note_conversation(user_id: event.user.id)

    if remberer.active_conversation?
      if !remberer.in_backoff?
        remberer.backoff
        event.respond "Quaaaack!!! :robot:"
        # event.respond(remberer.consume_message(user_id: event.user.id)) # TODO
      end
    else
      remberer.backoff unless remberer.in_backoff?
    end
  end

  private

  def remberer
    @remberer ||= ChatAbsurdityRemberer.new(server: server, channel: channel)
  end
end
