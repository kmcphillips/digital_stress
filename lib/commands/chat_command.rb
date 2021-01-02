# frozen_string_literal: true
class ChatCommand < BaseCommand
  def channels
    [
      "mandatemandate#general",
      "duck-bot-test#testing",
    ]
  end

  def response
    user = User.from_input(params.first, server: server)
    message = consume_message(user: user)

    "> **#{ message[:username] }**: #{ message[:message] }"
  end

  private

  def consume_message(user: nil)
    user ||= User.all(server: server).sample
    filename = Global.root.join("data", "absurdity_chats", "#{ user.id }.txt")

    lines = File.readlines(filename)
    lines = lines.shuffle
    message = lines.pop.strip

    File.open(filename, "w") { |f| f.write(lines.join("")) }

    { user_id: user.id, message: message, username: user.username }
  end

end
