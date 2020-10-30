# frozen_string_literal: true
class ChatCommand < BaseSubcommand
  def subcommands
    {
      on: "Enable responding to chat.",
      off: "Disable responding to chat.",
      status: "How is the absurdity responder doing?",
    }.freeze
  end

  private

  def on
    if remberer.enabled?
      "Chat is already enabled."
    else
      remberer.enable
      "Chat enabled."
    end
  end

  def off
    if remberer.enabled?
      remberer.disable
      "Chat disabled."
    else
      "Chat is already disabled."
    end
  end

  def status
    remberer.enabled_message
  end

  def remberer
    @remberer ||= ChatAbsurdityRemberer.new(server: server, channel: channel)
  end
end
