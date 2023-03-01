# frozen_string_literal: true
class TMinusResponder < BaseResponder
  T_MINUS_NUMBER_REGEX = /(?:^|\s)T-\s?([0-9]+)(?:$|\s)/i
  T_MINUS_CANCEL_REGEX = /(?:^|\s)T-\s?(nevermind)/i
  T_MINUS_AROUND_REGEX = /(?:^|\s)T-\s?(whenever|around|here|now)/i
  T_MINUS_WHATEVER_REGEX = /(?:^|\s)T-(?!shirt)\s?(.+)/i

  @waiting = {}

  class << self
    attr_reader :waiting
  end

  def channels
    [
      "mandatemandate",
      "duck-bot-test#testing",
    ].freeze
  end

  def respond
    channel_id = event.channel.id

    if match = T_MINUS_NUMBER_REGEX.match(event.message.content)
      minutes = match[1].to_i
      nonce = SecureRandom.hex
      Global.logger.info("handle T-#{ minutes } from: #{ event.message.content }")

      if minutes > 300
        event.channel.start_typing
        self.class.waiting[event.user.id] = nil
        sleep(1)
        event.respond("T-#{ minutes } minutes is too long to wait #{ mention }")
      elsif minutes == 0
        event.channel.start_typing
        self.class.waiting[event.user.id] = nil
        if user_online?
          event.respond("Oh #{ mention } I didn't see you there")
        else
          event.respond("You say zero minutes #{ mention } but yet you are not here")
        end
      else
        if self.class.waiting[event.user.id]
          event.respond("T-#{ minutes } minutes reset and counting #{ mention }")
        else
          event.respond("T-#{ minutes } minutes and counting #{ mention }")
        end
        self.class.waiting[event.user.id] = nonce
        Thread.new do
          sleep(minutes * 60)
          if self.class.waiting[event.user.id] == nonce
            self.class.waiting[event.user.id] = nil
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
    elsif match = T_MINUS_CANCEL_REGEX.match(event.message.content)
      event.channel.start_typing
      self.class.waiting[event.user.id] = nil
      event.respond("Ok fine #{ mention } see you another time then")
    elsif match = T_MINUS_AROUND_REGEX.match(event.message.content)
      event.channel.start_typing
      event.respond("Hi #{ mention }, thanks for hanging around")
    elsif match = T_MINUS_WHATEVER_REGEX.match(event.message.content)
      thing = match[1]
      event.channel.start_typing
      event.respond("Ok #{ mention } see you after #{ thing }")
    end
  end

  private

  def user_online?
    online_user_ids = event.server.voice_channels.map{ |c| c.users.map(&:id) }.flatten
    online_user_id = event.user.id

    Global.logger.info("[TMinusResponder] user_online?(#{ online_user_id }) and found #{ online_user_ids }")
    online_user_ids.include?(online_user_id)
  end
end
