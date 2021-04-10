# frozen_string_literal: true
class DailyAnnouncements < TaskBase
  def run
    count = 0

    Global.config.servers.each do |server_name, server_config|
      if server_config.tasks&.daily_announcements
        server_config.tasks.daily_announcements.each do |task_config|
          if Date.today.day == task_config.day.to_i && Date.today.month == task_config.month.to_i
            channel = Pinger.find_channel(server: server_name, channel: task_config.channel)
            channel.send_message(render(task_config.message))
            count += 1
          end
        end
      end
    end

    count
  end

  private

  def render(message)
    template = ERB.new(message)
    template.result(binding) # TODO: expose a more useful binding here rather than counting on globals
  end
end
