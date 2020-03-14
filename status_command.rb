# frozen_string_literal: true
class StatusCommand < BaseCommand
  def response
    ip_address = `hostname`.strip
    hostname = `hostname -I`.split(" ").first

    lines = [
      ":duck: on `#{ hostname }` `(#{ ip_address })`",
    ]

    if Recorder.record_server?(@event) || (@event.channel.pm? && @event.channel.name == "kmcphillips")
      counts = @datastore.counts
      last = @datastore.last
      lines << "Last message by **#{ last[0] }** #{ TimeDifference.between(Time.at(last[3]), Time.now).humanize || 'a second' } ago"
      counts.each{ |r| lines << "  **#{ r[0] }**: #{ r[2] } messages" }
    end

    lines.reject(&:blank?)
  end
end
