# frozen_string_literal: true

module Texter
  extend self

  def send_text(phone_number:, message:, country_code: nil)
    Global.logger.info("[Texter][send_text] phone_number: #{phone_number} message: #{message}")

    response = twilio_client.messages.create(
      from: outgoing_phone_number(country_code: country_code),
      to: phone_number,
      body: message
    )

    Global.logger.info("[Texter][send_text] sid: #{response.sid}")

    response.sid
  end

  private

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new(account_sid, auth_token)
  end

  def account_sid
    Global.config.twilio.account_sid
  end

  def auth_token
    Global.config.twilio.auth_token
  end

  def outgoing_phone_number(country_code: nil)
    country_code = country_code.presence&.to_s&.strip&.downcase&.presence || "default"
    Global.config.twilio.outgoing_phone_numbers[country_code] || raise("No outgoing phone number found for country code: #{country_code}")
  end
end
