# frozen_string_literal: true
class DailyAnnouncements < TaskBase
  def run
    Global.config.servers.each do |server_name, server_config|
      if server_config.tasks&.daily_announcements
        server_config.tasks.daily_announcements.each do |task_config|
          if Date.today.day == task_config.day.to_i && Date.today.month == task_config.month.to_i
            channel = Pinger.find_channel(server: server_name, channel: task_config.channel)
            channel.send_message(task_config.message)
          end
        end
      end
    end

    nil
  end
end
