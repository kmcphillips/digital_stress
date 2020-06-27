# frozen_string_literal: true
class StatusCommand < BaseCommand
  def response
    ip_address = `hostname`.strip
    hostname = `hostname -I`.split(" ").first
    server = @event.server&.name

    lines = [
      ":duck: on `#{ hostname }` `(#{ ip_address })`",
    ]

    if server && last_learned = Learner.last(server: server)
      lines << "Learned **#{ Learner.count(server: server) }** things. Last learn was #{ TimeDifference.between(Time.at(last_learned[:timestamp]), Time.now).humanize.downcase || 'a second' } ago."
    end

    if Recorder.record_channel?(@event) || (@event.channel.pm? && @event.channel.name == "kmcphillips")
      counts = Recorder.counts
      last = Recorder.last
      lines << "Last message by **#{ last[:username] }** #{ TimeDifference.between(Time.at(last[:timestamp]), Time.now).humanize.downcase || 'a second' } ago."
      counts.each{ |r| lines << "  **#{ r[:username] }**: #{ r[:count] } messages" }
    end

    lines.reject(&:blank?)
  end
end
