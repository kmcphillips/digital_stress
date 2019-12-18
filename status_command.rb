# frozen_string_literal: true
class StatusCommand < BaseCommand
  def response
    ip_address = `hostname`.strip
    hostname = `hostname -I`.split(" ").first
    counts = @datastore.counts
    last = @datastore.last

    lines = [
      ":duck: on `#{ hostname }` `(#{ ip_address })`",
      "Last message by **#{ last[0] }** #{ TimeDifference.between(Time.at(last[3]), Time.now).humanize || 'a second' } ago",
    ] + counts.map{ |r| "  **#{ r[0] }**: #{ r[2] } messages" }

    lines.reject(&:blank?)
  end
end
