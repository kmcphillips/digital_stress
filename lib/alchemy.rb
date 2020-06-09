# frozen_string_literal: true
class Alchemy < BaseResponder
  EMOJI = {
    check:   ["✅", "☑", "✔",].freeze,
    earth:   ["🏔", "⛰", "🗻", "🌋", "🌍", "🌎", "🌏",].freeze,
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
    "duck-bot-test#testing",
  ].freeze

  RESPONSES = [
    "**4/4**",
    "Full strength!",
    "Everyone accounted for tonight.",
    "Full strength mandate",
    "We are 4/4 for tonight",
    "nice",
    "Quack, full strength",
    "4 of 4",
    "Mandate: Full Strength Edition",
    "Quack! 🔥🌊🌬️🏔️",
    "4 / 4",
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

      party = Party.new(channel)

      if party.element_for?(element, event.author)
        if party.present?(element)
          event.message.react(EMOJI[:repeat])
        else
          party.present!(element)
          count = EMOJI[:count][party.size - 1]
          event.channel.start_typing if party.full_strength? # this works around the reaction ratelimit
          event.message.react(count)
        end

        if party.full_strength?
          party.clear
          event.respond(RESPONSES.sample)
        end
      else
        event.message.react(EMOJI[:wrong])
      end
    end
  end

  class Party
    def initialize(channel)
      @channel = channel
      @ttl = 18.hours.to_i
    end

    def present?(element)
      !!KV.read(key(element))
    end

    def present!(element)
      KV.write(key(element), Time.now.to_i, @ttl)
    end

    def size
      [
        !!KV.read(key(:fire)),
        !!KV.read(key(:earth)),
        !!KV.read(key(:water)),
        !!KV.read(key(:wind)),
      ].count(true)
    end

    def full_strength?
      size == 4
    end

    def clear
      KV.delete(key(:fire))
      KV.delete(key(:earth))
      KV.delete(key(:water))
      KV.delete(key(:wind))

      true
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

    private

    def key(element)
      "#{ @channel }-#{ element.to_s }"
    end
  end
end
