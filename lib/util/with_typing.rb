# frozen_string_literal: true

module WithTyping
  extend self

  def threaded(discord_channel, enable: true, times: 6)
    return yield unless enable

    discord_channel.start_typing
    begin
      typing_thread = Thread.new do
        times.times do
          sleep 4
          discord_channel.start_typing
        end
      end
      yield
    ensure
      typing_thread&.kill
    end
  end
end
