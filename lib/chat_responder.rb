# frozen_string_literal: true
class ChatResponder < BaseResponder
  def respond
    return unless ChatAbsurdityRemberer::CHANNELS.include?("#{ event.server&.name }##{ event.channel&.name }")
    return unless remberer.enabled?

    # TODO
  end

  private

  def remberer
    @remberer ||= ChatAbsurdityRemberer.new(server: server, channel: channel)
  end
end
