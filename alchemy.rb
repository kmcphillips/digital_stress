# frozen_string_literal: true
class Alchemy < BaseResponder
  EMOJI = {
    check:   ["✅", "☑", "✔",].freeze,
    earth:   ["🏔", "⛰", "🗻",].freeze,
    fire:    ["🔥", "🧨", "🎆",].freeze,
    wind:    ["🌬", "🎐", "☁", "🌩", "🌪", "💨",].freeze,
    water:   ["🚰", "💧", "💦", "🚿", "🛀", "🛁", "⛈", "🌧", "🌦",].freeze,
    count:   ["1️⃣", "2️⃣", "3️⃣", "4️⃣",].freeze,
    weird:   "❓",
  }.freeze

  CHANNELS = [
    "duck-bot-test#general",
  ].freeze

  @parties = {}

  class << self
    attr_reader :parties
  end

  def respond
    channel = "#{ event.server&.name }##{ event.channel&.name }"
    return unless CHANNELS.include?(channel)

    text = event.message.content || ""
    text = text.gsub(/\s+/, "")

    chars = text[0, 6].chars
    return unless chars.find { |c| EMOJI[:check].include?(c) }

    elements = [:earth, :fire, :wind, :water].select { |e| (chars & EMOJI[e]).any? }
    return if elements.none?

    if elements.many?
      event.message.react(EMOJI[:weird])
    else
      element = elements.first

      Alchemy.parties[channel] = Party.new if !Alchemy.parties[channel] || Alchemy.parties[channel].expired?

      if !Alchemy.parties[channel].present?(element)
        Alchemy.parties[channel].present!(element)
        count = EMOJI[:count][Alchemy.parties[channel].size - 1]
        event.message.react(count)
      end

      if Alchemy.parties[channel].size == 4
        Alchemy.parties[channel] = nil
        event.channel.start_typing
        event.respond("Full strength!")
      end
    end
  end

  class Party
    def initialize
      @stared_at = Time.now
      @expires_at = @stared_at + 18.hours
      @elements = []
    end

    def expired?
      Time.now > @expires_at
    end

    def present?(element)
      @elements.include?(element.to_sym)
    end

    def present!(element)
      @elements << element.to_sym unless present?(element)
    end

    def size
      @elements.size
    end
  end
end
