# frozen_string_literal: true
class ChatCommand < BaseCommand
  def channels
    [
      "mandatemandate#general",
      "mandatemandate#quigital",
      "duck-bot-test#testing",
    ]
  end

  def response
    user = User.from_input(params.first, server: server)
    raise "Cannot find user: #{ params.first }" if params.first.present? && user.blank?
    user = User.all(server: server).sample if user.blank?
    chat = AbsurdityChatStore.consume(user_id: user.id, server: server)

    if chat
      "> **#{ chat.username }**: #{ chat.message }"
    else
      ":bangbang: No more chats for #{ user.username }"
    end
  end
end
