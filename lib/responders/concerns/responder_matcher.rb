# frozen_string_literal: true
module ResponderMatcher
  private

  def respond_match(regex, reply_message, source: nil, chance: nil, channels: nil, users: nil)
    source ||= text
    return if channels && !Array(channels).include?("#{ server }##{ channel }")
    return if users && !Array(users).map(&:id).include?(user.id)
    if source.match?(regex) && (!chance || rand < chance)
      reply_message_text = if reply_message.respond_to?(:call)
        reply_message.call
      else
        reply_message
      end

      event.respond(reply_message_text) if reply_message_text.present?
    end
  end

  def react_match(regex, emoji, source: nil, chance: nil, channels: nil, users: nil)
    source ||= text
    return if channels && !Array(channels).include?("#{ server }##{ channel }")
    return if users && !Array(users).map(&:id).include?(user.id)
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
      return emoji_obj if emoji_obj.name == str.gsub(":", "")
    end
    nil
  end
end
