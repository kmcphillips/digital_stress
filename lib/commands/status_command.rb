# frozen_string_literal: true
class StatusCommand < BaseCommand
  PM_STATUS = [
    "kmcphillips",
  ]

  def response
    ip_address = `hostname`.strip
    hostname = `hostname -I`.split(" ").first

    lines = [
      ":duck: on `#{ hostname }` `(#{ ip_address })`",
    ]

    if server && last_learned = Learner.last(server: server)
      lines << "Learned **#{ Learner.count(server: server) }** things. Last learn was #{ TimeDifference.between(Time.at(last_learned[:timestamp]), Time.now).humanize.downcase || 'a second' } ago."
    end

    if Recorder.record_server?(server: server) || (event.channel.pm? && PM_STATUS.include?(event.channel.name))
      counts = Recorder.counts
      last = Recorder.last
      lines << "Last message by **#{ User.from_id(last[:user_id], server: last[:server])&.username || last[:user_id] }** #{ TimeDifference.between(Time.at(last[:timestamp]), Time.now).humanize.downcase || 'a second' } ago."
      counts.each{ |r| lines << "  **#{ User.from_id(r[:user_id], server: r[:server])&.username || r[:user_id] }**: #{ Formatter.number(r[:count]) } messages (#{ Formatter.number(r[:words]) } words)" }
    end

    if !event.channel.pm?
      lines << "This channel is **#{ Recorder.off_the_record?(server: server, channel: channel) ? "OFF" : "ON" }** the record."
    end

    lines.reject(&:blank?)
  end
end
