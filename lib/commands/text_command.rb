# frozen_string_literal: true

class TextCommand < BaseCommand
  def channels
    [
      "mandatemandate",
      "duck-bot-test#testing"
    ]
  end

  def response
    return ":question: Quack! `duck text USER and the message after`" if params.none?

    name = params.shift
    user = User.from_input(name, server: server)

    return ":question: Quack! Can't figure out who the user is from '#{name}'" unless user
    return ":no_mobile_phones: Quack! I don't know #{user.username}'s phone number." unless user.phone_number

    text = params.join(" ")

    return ":question: Quack! Your message is blank." if text.blank?

    Texter.send_text(phone_number: user.phone_number, message: "(🦆) #{text}")
    event.message.react("📲")
  end

  def typing?
    false
  end
end
