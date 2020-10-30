# frozen_string_literal: true
class ChatResponder < BaseResponder
  def respond
    return unless ChatAbsurdityRemberer::CHANNELS.include?("#{ event.server&.name }##{ event.channel&.name }")
    return unless remberer.enabled?

    remberer.note_conversation(user_id: event.user.id)

    if remberer.active_conversation?
      if !remberer.in_backoff?
        remberer.backoff

        absurdity = remberer.consume_message

        event.respond("> <@#{ absurdity[:user_id] }> : #{ absurdity[:message] }")
      end
    else
      remberer.backoff
    end
  end

  private

  def remberer
    @remberer ||= ChatAbsurdityRemberer.new(server: server, channel: channel)
  end
end
