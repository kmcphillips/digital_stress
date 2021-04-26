# frozen_string_literal: true
class DailyAnnouncements < TaskBase
  def run
    results = []

    # Config file defined tasks
    Global.config.servers.each do |server_name, server_config|
      if server_config.tasks&.daily_announcements
        server_config.tasks.daily_announcements.each do |task_config|
          results << process_daily_announcement(task_config, server: server_name)
        end
      end
    end

    results.select(&:present?).count
  end

  private

  def render(message)
    template = ERB.new(message)
    template.result(binding) # TODO: expose a more useful binding here rather than counting on globals
  end

  def process_daily_announcement(task_config, server:)
    if triggers_now?(task_config)
      channel = Pinger.find_channel(server: server, channel: task_config.channel)
      channel.send_message(render(task_config.message))

      true
    end
  end

  def triggers_now?(task_config)
    if task_config.weekday || task_config.weekdays
      days = Array(task_config.weekday || task_config.weekdays).compact.map(&:downcase)
      days.include?(Date::DAYNAMES[Date.today.wday].downcase)
    else
      return false if task_config.year.present? && task_config.year.to_i != Date.today.year
      return false if task_config.month.present? && task_config.month.to_i != Date.today.month
      Date.today.day == task_config.day.to_i
    end
  end
end
