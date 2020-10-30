# frozen_string_literal: true
class ChatResponder < BaseResponder
  def respond
    return unless ChatAbsurdityRemberer::CHANNELS.include?("#{ event.server&.name }##{ event.channel&.name }")

    # TODO
  end
end
