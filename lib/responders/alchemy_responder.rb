# frozen_string_literal: true
class AlchemyResponder < BaseResponder
  EMOJI = {
    check:   ["✅", "☑", "✔", "👻",].freeze,
    earth:   ["🏔", "⛰", "🗻", "🌋", "🌍", "🌎", "🌏", "🪨", "🥌", "🌐", "🦬", "🛢️"].freeze,
    fire:    ["🔥", "🧨", "🎆", "🚒", "🧨", "❤️‍🔥", "🧑‍🚒", "👨‍🚒", "👩‍🚒", "❤️‍🔥", "🧯"].freeze,
    wind:    ["🌬", "🎐", "☁", "🌩", "🌪", "💨", "🍃", "🪈"].freeze,
    water:   ["🌊", "🚰", "💧", "💦", "🚿", "🛀", "🛁", "⛈", "🌧", "🌦",].freeze,
    count:   ["1️⃣", "2️⃣", "3️⃣", "4️⃣",].freeze,
    wrong:   "🚫",
    repeat:  "🔁",
  }.freeze

  RESPONSES = [
    "Everyone accounted for tonight.",
    "Full strength mandate",
    "We are 4/4 for tonight",
    "nice",
    "Quack, full strength",
    "4 of 4",
    "Mandate: Full Strength Edition",
    "Quack! 🔥🌊🌬️🏔️",
    "Full strength. Keep it light, keep it tight.",
    "That's ✅✅✅✅ / 4",
    "Full strength.",
  ].freeze
  CHARS_INTO_MESSAGE = 6

  @parties = {}

  class << self
    attr_reader :parties

    def element_from_message(message)
      message = message || ""
      message = message.gsub(/\s+/, "")

      chars = message[0, CHARS_INTO_MESSAGE].chars
      return nil unless chars.find { |c| EMOJI[:check].include?(c) }

      elements = [:earth, :fire, :wind, :water].select { |e| (chars & EMOJI[e]).any? }
      elements.first
    end
  end

  def channels
    [
      "mandatemandate#general",
      "mandatemandate#dnd",
      "duck-bot-test#testing",
    ].freeze
  end

  def respond
    server = event.server&.name || ""
    channel = event.channel&.name || ""
    element = self.class.element_from_message(event.message.content)

    if element
      party = Party.new(server: server, channel: channel)

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
    attr_reader :server, :channel, :ttl

    def initialize(server:, channel:)
      @server = server
      @channel = channel
      @ttl = 18.hours.to_i
    end

    def present?(element)
      !!kv_store.read(key(element))
    end

    def present!(element)
      kv_store.write(key(element), Time.now.to_i, ttl: ttl)
    end

    def size
      [
        !!kv_store.read(key(:fire)),
        !!kv_store.read(key(:earth)),
        !!kv_store.read(key(:water)),
        !!kv_store.read(key(:wind)),
      ].count(true)
    end

    def full_strength?
      size == 4
    end

    def clear
      kv_store.delete(key(:fire))
      kv_store.delete(key(:earth))
      kv_store.delete(key(:water))
      kv_store.delete(key(:wind))

      true
    end

    def element_for?(element, author)
      user = User.from_discord(author, server: server)

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
      "#{ server }##{ channel }-#{ element.to_s }"
    end

    def kv_store
      Global.kv
    end
  end
end
