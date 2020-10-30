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
    # TODO
  end

  def off
    # TODO
  end

  def status
    # TODO
  end
end
