# frozen_string_literal: true
class NotificationsCommand < BaseSubcommand
  CHANNELS = [
    "mandatemandate#general",
    "duck-bot-test#testing",
  ].freeze

  def subcommands
    {
      mute: "Temporarily silence notifications.",
      off: "Turn off notifications.",
      on: "Turn on notifications.",
    }.freeze
  end

  def on
    Flags.deactivate("silence_notifications", server: server)
    "🔉 Quack! Notifications turned on."
  end

  def off
    Flags.activate("silence_notifications", server: server)
    "🔇 Quack! Notifications turned off."
  end

  def mute
    Flags.activate("silence_notifications", server: server, seconds: 3600)
    "🔇 Quack! Notifications muted for one hour."
  end
end
