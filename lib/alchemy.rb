# frozen_string_literal: true
class Alchemy < BaseResponder
  EMOJI = {
    check:   ["✅", "☑", "✔",].freeze,
    earth:   ["🏔", "⛰", "🗻",].freeze,
    fire:    ["🔥", "🧨", "🎆",].freeze,
    wind:    ["🌬", "🎐", "☁", "🌩", "🌪", "💨",].freeze,
    water:   ["🌊", "🚰", "💧", "💦", "🚿", "🛀", "🛁", "⛈", "🌧", "🌦",].freeze,
    count:   ["1️⃣", "2️⃣", "3️⃣", "4️⃣",].freeze,
    weird:   "❓",
    wrong:   "🚫",
    repeat:  "🔁",
  }.freeze

  CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#quigital",
    "duck-bot-test#general",
  ].freeze

  RESPONSES = [
    "**4/4**",
    "Full strength!",
    "Everyone accounted for tonight.",
    "Full strength mandate",
    "We are 4/4",
    "nice",
    "Quack, full strength",
    "4 of 4",
    "Mandate: Full Strength Edition",
    "Quack! 🔥🌊🌬️🏔️",
    "4 / 4",
    "Full strength, quack!",
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

      if Alchemy.parties[channel].element_for?(element, event.author)
        if Alchemy.parties[channel].present?(element)
          event.message.react(EMOJI[:repeat])
        else
          Alchemy.parties[channel].present!(element)
          count = EMOJI[:count][Alchemy.parties[channel].size - 1]
          event.channel.start_typing if Alchemy.parties[channel].full_strength? # this works around the reaction ratelimit
          event.message.react(count)
        end
        if Alchemy.parties[channel].full_strength?
          Alchemy.parties[channel] = nil
          event.respond(RESPONSES.sample)
        end
      else
        event.message.react(EMOJI[:wrong])
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

    def full_strength?
      @elements.size == 4
    end

    def element_for?(element, author)
      user = User.from_discord(author)

      case element
      when :fire then user.kevin?
      when :earth then user.eliot?
      when :water then user.dave?
      when :wind then user.patrick?
      else
        raise "Unknown element '#{ element }'"
      end
    end
  end
end
