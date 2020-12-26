# frozen_string_literal: true
module Texter
  extend self

  def send_text(phone_number:, message:)
    Log.info("[Texter][send_text] phone_number: #{ phone_number } message: #{ message }")

    response = twilio_client.messages.create(
      from: outgoing_phone_number,
      to: phone_number,
      body: message,
    )

    Log.info("[Texter][send_text] sid: #{ response.sid }")

    response.sid
  end

  private

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(account_sid, auth_token)
  end

  def account_sid
    Configuration.twilio.account_sid
  end

  def auth_token
    Configuration.twilio.auth_token
  end

  def outgoing_phone_number
    Configuration.twilio.outgoing_phone_number
  end
end
