# frozen_string_literal: true
class ChatCommand < BaseCommand
  def channels
    [
      "mandatemandate#general",
      "duck-bot-test#testing",
    ]
  end

  def response
    desired_user_id = nil

    if params.any?
      name = params.first
      user = User.from_fuzzy_match(name) || User.from_id(Pinger.extract_user_id(name))
      desired_user_id = user.id if user
    end

    message = consume_message(user_id: desired_user_id)

    "> **#{ message[:username] }: #{ message[:message] }"
  end

  private

  def consume_message(user_id: nil)
    user_id ||= User::MANDATE_CONFIG_BY_ID.keys.sample
    user = User::MANDATE_CONFIG_BY_ID[user_id]
    username = user["username"]
    filename = File.join(File.dirname(__FILE__), "..", "..", "absurdity_chats", "#{ user_id }.txt")

    lines = File.readlines(filename)
    lines = lines.shuffle
    message = lines.pop.strip

    File.open(filename, "w") { |f| f.write(lines.join("")) }

    { user_id: user_id, message: message, username: username }
  end

end
