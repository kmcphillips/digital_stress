# frozen_string_literal: true

class SummaryCommand < BaseCommand
  def response
    if event.channel.pm?
      "Quack, I can't summarize a direct message."
    elsif !Recorder.record_channel?(server: server, channel: channel)
      "Quack, I can't provide a summary of a channel I am not recording."
    else
      if query.present?
        days = /^(\d+)\s?+d/i.match(query)
        days = days[1].to_i if days

        return "Quack, could not parse the number of days from '#{query}'." if days.blank?
      else
        days = 1
      end

      date = start_of_day(days)
      date_string = date.strftime("%B %d, %Y")
      messages = Recorder.all_since(server: server, channel: channel, since: date)

      if messages.empty?
        "Quack, no messages to summarize since #{date_string}."
      else
        conversation = ""
        message_count = 0

        messages.each do |message|
          name = User.from_id(message[:user_id], server: server)&.mandate_display_name.presence || message[:username]
          message_text = "#{name}: #{message[:message]}"

          if conversation.split.size + message_text.split.size > max_length_in_words
            break
          else
            message_count += 1
            conversation = "#{message_text}\n#{conversation}"
          end
        end

        summary = call_open_ai(conversation)

        if message_count == messages.count
          "#{summary}\n**(Summary of all #{message_count} messages since #{date_string})**"
        else
          "#{summary}\n**(Summary of #{message_count} messages since #{date_string})**"
        end
      end
    end
  end

  private

  def max_length_in_words
    1400
  end

  def start_of_day(days = 1)
    current_time = Time.now.utc
    result = Time.new(
      current_time.year,
      current_time.month,
      current_time.day,
      8, 0, 0, "UTC" # 8AM UTC is 3AM/4AM EST/EDT
    )
    result -= 1.day if result > current_time
    days = [(days.to_i - 1), 0].max
    result -= days.days
    result
  end

  def call_open_ai(conversation)
    OpenaiClient.chat("Provide a summary of this chat conversation:\n\n#{conversation}\n\n").first
  end
end
