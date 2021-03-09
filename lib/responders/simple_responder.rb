# frozen_string_literal: true
class SimpleResponder < BaseResponder
  def respond
    react_match(/\bheat\b/i, "🔥")
    react_match(/\bhwat\b/i, "🔥")
    react_match(/tight/i, "🤏")
    react_match(/(noot|neet)/i, "👢")
    react_match(/(good|great|nice|best) duck/i, "❤️")
    react_match(/quigital/i, "quigital", channels: [ "mandatemandate#general", "duck-bot-test#testing" ])

    respond_match(/hang(ing)?.?in.?there/i, "https://i.imgur.com/1FlykyH.jpg")
    respond_match(/\bheat\b/i, "don't be hwat...", chance: 0.08)
    respond_match(/several people are typing/i, "https://i.kym-cdn.com/photos/images/newsfeed/001/249/060/9c3.gif")
    respond_match(/safe/i, "https://i.imgur.com/1WReL2h.jpg")
    respond_match(/brain injur|concussion/i, "https://media3.giphy.com/media/NhXhI7kHCwxRC/giphy.gif", chance: 0.3)
  end

  private

  def respond_match(regex, reply_message, source: nil, chance: nil, channels: nil)
    source ||= text
    return if channels && !Array(channels).include?("#{ server }##{ channel }")
    if source.match?(regex) && (!chance || rand < chance)
      event.respond(reply_message)
    end
  end

  def react_match(regex, emoji, source: nil, chance: nil, channels: nil)
    source ||= text
    return if channels && !Array(channels).include?("#{ server }##{ channel }")
    if source.match?(regex) && (!chance || rand < chance)
      begin
        emoji = find_emoji_on_server(emoji) || emoji
        event.message.react(emoji)
      rescue RestClient::BadRequest => e
        Global.logger.error("[SimpleResponder] #react_match emoji #{ emoji } does not exist on #{ server }##{ channel }")
      end
    end
  end

  def find_emoji_on_server(str)
    event.message.server.emoji.each do |id, emoji_obj|
      return emoji_obj if emoji_obj.name == str
    end
    nil
  end
end
