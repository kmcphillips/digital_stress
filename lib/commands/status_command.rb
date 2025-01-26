# frozen_string_literal: true

class StatusCommand < BaseCommand
  PM_STATUS = [
    "kmcphillips"
  ]

  def response
    lines = []

    env_info = if SystemInfo.flyio?
      "**fly.io** `#{SystemInfo.instance}` in **#{SystemInfo.region}** region (#{SystemInfo.memory}mb RAM)"
    else
      "`#{SystemInfo.hostname}` `(#{SystemInfo.ip_address})`"
    end

    flags = if SystemInfo.recently_deployed?
      " :rocket:"
    else
      ""
    end

    lines << "**@duck** `#{SystemInfo.git_revision || "unknown"}`#{flags} running on #{env_info} using `ruby #{RUBY_VERSION}`"
    lines << "• #{Global.kv}"

    lines << if Global.db.class.to_s == "Sequel::SQLite::Database"
      "• SQLite in `#{File.basename(Global.db.opts[:database])}`"
    elsif Global.db.class.to_s == "Sequel::MySQL::Database"
      "• MySQL `#{Global.db.opts[:database]}` at `#{Global.db.opts[:host]}:#{Global.db.opts[:port]}`"
    else
      "• #{Global.db}"
    end

    if server
      lines << "For server **#{server}**:"

      if last_learned = Learner.last(server: server)
        lines << "• Learned **#{Learner.count(server: server)}** things. Last learn was #{TimeDifference.between(Time.at(last_learned[:timestamp]), Time.now).humanize.downcase || "a second"} ago."
      end

      if Recorder.record_server?(server: server) || (event.channel.pm? && PM_STATUS.include?(event.channel.name))
        counts = Recorder.counts(server: server)
        last = Recorder.last(server: server)
        lines << "• Last message by **#{User.from_id(last[:user_id], server: server)&.username || last[:user_id]}** #{TimeDifference.between(Time.at(last[:timestamp]), Time.now).humanize.downcase || "a second"} ago."
        counts.each do |r|
          word_count = r[:words]
          message_count = r[:count]
          words_average = (word_count / message_count).to_i
          lines << "  **#{User.from_id(r[:user_id], server: server)&.username || r[:user_id]}**: #{Formatter.number(message_count)} messages, #{Formatter.number(word_count)} words (#{words_average} words/message)"
        end
      end

      if !event.channel.pm?
        lines << "• This channel is **#{Recorder.off_the_record?(server: server, channel: channel) ? "OFF" : "ON"}** the record."
      end
    end

    if query.downcase.include?("sweep")
      count = Recorder.delete_sweep.count
      lines << "• Performed a `Recorder.delete_sweep` and pruned #{count} records."
    end

    lines.reject(&:blank?)
  end
end
