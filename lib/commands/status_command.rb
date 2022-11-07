# frozen_string_literal: true
class StatusCommand < BaseCommand
  PM_STATUS = [
    "kmcphillips",
  ]

  def response
    lines = []

    if SystemInfo.flyio?
      lines << "**@duck** running on **fly.io** `#{ ENV["FLY_ALLOC_ID"] }` in **#{ SystemInfo.region }** region (#{ ENV["FLY_VCPU_COUNT"] } CPU #{ ENV["FLY_VM_MEMORY_MB"] }mb RAM)  running `ruby #{ RUBY_VERSION}`"
    elsif SystemInfo.digitalocean?
        lines << "**@duck** running on **DigitalOcean** `#{ SystemInfo.hostname }` `(#{ SystemInfo.ip_address })` running `ruby #{ RUBY_VERSION}`"
    else
      lines << "**@duck** running on `#{ SystemInfo.hostname }` `(#{ SystemInfo.ip_address })` running `ruby #{ RUBY_VERSION}`"
    end

    lines << "Using:"
    lines << "• #{ Global.kv.to_s }"

    if Global.db.class.to_s == "Sequel::SQLite::Database"
      lines << "• SQLite in `#{ File.basename(Global.db.opts[:database]) }`"
    elsif Global.db.class.to_s == "Sequel::MySQL::Database"
      lines << "• MySQL `#{ Global.db.opts[:database] }` at `#{ Global.db.opts[:host] }:#{ Global.db.opts[:port] }`"
    else
      lines << "• #{ Global.db.to_s }"
    end

    if server
      lines << "For server **#{ server }**:"

      if last_learned = Learner.last(server: server)
        lines << "• Learned **#{ Learner.count(server: server) }** things. Last learn was #{ TimeDifference.between(Time.at(last_learned[:timestamp]), Time.now).humanize.downcase || 'a second' } ago."
      end

      if Recorder.record_server?(server: server) || (event.channel.pm? && PM_STATUS.include?(event.channel.name))
        counts = Recorder.counts(server: server)
        last = Recorder.last(server: server)
        lines << "• Last message by **#{ User.from_id(last[:user_id], server: server)&.username || last[:user_id] }** #{ TimeDifference.between(Time.at(last[:timestamp]), Time.now).humanize.downcase || 'a second' } ago."
        counts.each{ |r| lines << "  **#{ User.from_id(r[:user_id], server: server)&.username || r[:user_id] }**: #{ Formatter.number(r[:count]) } messages (#{ Formatter.number(r[:words]) } words)" }
      end

      if !event.channel.pm?
        lines << "• This channel is **#{ Recorder.off_the_record?(server: server, channel: channel) ? "OFF" : "ON" }** the record."
      end
    end

    lines.reject(&:blank?)
  end
end
