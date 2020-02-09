# frozen_string_literal: true
class TMinus < BaseResponder
  T_MINUS_NUMBER_REGEX = /^T-\s?([0-9]+)(?:$|\s)/i

  @waiting = {}

  class << self
    attr_reader :waiting
  end

  def respond
    match = T_MINUS_NUMBER_REGEX.match(event.message.content)
    if match
      minutes = match[1].to_i
      channel_id = event.channel.id
      mention = event.user.mention
      nonce = SecureRandom.hex
      Log.info("handle T-#{ minutes } from: #{ event.message.content }")

      if minutes > 300
        event.channel.start_typing
        sleep(1)
        event.respond("T-#{ minutes } minutes is too long to wait #{ mention }")
      elsif minutes == 0
        event.channel.start_typing
        if user_online?
          event.respond("You say zero minutes #{ mention } but yet you are not here")
        else
          event.respond("Oh #{ mention } I didn't see you there")
        end
      else
        if TMinus.waiting[event.user.id]
          event.respond("T-#{ minutes } minutes reset and counting #{ mention }")
        else
          event.respond("T-#{ minutes } minutes and counting #{ mention }")
        end
        TMinus.waiting[event.user.id] = nonce
        Thread.new do
          sleep(minutes * 60)
          if TMinus.waiting[event.user.id] == nonce
            TMinus.waiting[event.user.id] = nil
            event.channel.start_typing
            sleep(2)
            if user_online?
              bot.send_message(channel_id, "T-#{ minutes } minutes is up and #{ mention } made it on time :ok_hand:")
            else
              bot.send_message(channel_id, "T-#{ minutes } minutes is up and #{ mention } is late :alarm_clock:")
            end
          end
        end
      end
    end
  end

  private

  def user_online?
    event.server.voice_channels.map{ |c| c.users.map(&:id) }.flatten.include?(event.user.id)
  end
end
