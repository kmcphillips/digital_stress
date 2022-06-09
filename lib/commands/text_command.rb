# frozen_string_literal: true
class TextCommand < BaseCommand
  def channels
    [
      "mandatemandate#general",
      "duck-bot-test#testing",
    ]
  end

  def response
    if params.any?
      name = params.shift
      user = User.from_input(name, server: server)

      if user
        if user.phone_number
          text = params.join(" ")

          if !text.blank?
            Texter.send_text(phone_number: user.phone_number, message: "🦆: #{ text }")
            event.message.react("📲")
          else
            ":question: Quack! Your message is blank."
          end
        else
          ":no_mobile_phones: Quack! I don't know #{ user.username }'s phone number."
        end
      else
        ":question: Quack! Can't figure out who the user is from '#{ name }'"
      end
    else
      ":question: Quack! `duck text USER and the message after`"
    end
  end

  def typing?
    false
  end
end
