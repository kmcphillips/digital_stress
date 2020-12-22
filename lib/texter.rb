# frozen_string_literal: true
module Texter
  extend self

  TWILIO_CONFIG = JSON.parse(ENV["TWILIO_CONFIG"]).symbolize_keys!.freeze

  def send_text(phone_number:, message:)
    Log.info("[Texter][send_text] phone_number: #{ phone_number } message: #{ message }")

    response = twilio_client.messages.create(
      from: TWILIO_CONFIG.fetch(:outgoing_phone_number),
      to: phone_number,
      body: message,
    )

    Log.info("[Texter][send_text] sid: #{ response.sid }")

    response.sid
  end

  private

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(
      TWILIO_CONFIG.fetch(:account_sid),
      TWILIO_CONFIG.fetch(:auth_token),
    )
  end
end
