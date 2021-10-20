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
      product: "Generate a smarthome product."
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

  def product
    prompt = "This is a brainstorming session to create new smarthome technology products. Our company wants our new products to have a catchy title, that references the functionality of the product. Sometimes the product name includes a completely made-up word. I'll describe what the product does, and you'll give it a name.

    Description: #{ params[1..-1].join(" ") }
    Name: "
    OpenaiData.completion(prompt, max_tokens: rand(100..160))
  end
end
