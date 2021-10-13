# frozen_string_literal: true
class OpenaiCommand < BaseSubcommand
  CHANNELS = [
    "mandatemandate#general",
    "duck-bot-test#testing",
  ].freeze

  def channels
    CHANNELS
  end

  def subcommands
    {
      classification: "Toggle classifying messages.",
    }.freeze
  end

  private

  def classification
    action = (params[1] || "").downcase
    if action == "on"
      OpenaiData.classifying_on(server: server, channel: channel)
      "🤖 Classification for this channel is now **on**."
    elsif action == "off"
      OpenaiData.classifying_off(server: server, channel: channel)
      "🤖 Classification for this channel is now **off**."
    else
      "🤖 Must enter either **on** or **off**. Currently is **#{ OpenaiData.classifying?(server: server, channel: channel) ? 'on' : 'off' }**."
    end
  end
end
