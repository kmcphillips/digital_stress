# frozen_string_literal: true

# Take some of the private methods from SummaryCommand to DRY
class WordsCommand < SummaryCommand
  def response
    random = false

    if event.channel.pm?
      "Quack, I can't summarize a direct message."
    elsif !Recorder.record_channel?(server: server, channel: channel)
      "Quack, I can't provide a summary of a channel I am not recording."
    else
      if query.present?
        if query.downcase.strip == "random"
          days = 1
          random = true
        else
          days = Formatter.parse_days_from(query)
          return "Quack, could not parse the number of days from '#{query}'." if days.blank?
          return "Quack, needs to be at least 1 day." if days < 1
          return "Quack, needs to be less than #{MAX_DAYS} days." if days > MAX_DAYS
        end
      else
        days = 5
      end

      start_message_id = nil

      if random
        random_message = Recorder.random(server: server, channel: channel)
        random_time = Time.at(random_message[:timestamp])
        start_time = Time.new(
          random_time.year,
          random_time.month,
          random_time.day,
          8, 0, 0, "UTC" # 8AM UTC is 3AM/4AM EST/EDT
        )
        end_time = start_time + 1.day
      else
        start_time = start_of_day(1)
        end_time = Time.now.utc
      end

      responses = []

      days.times do |day|
        messages = Recorder.all_between(server: server, channel: channel, start_time: start_time, end_time: end_time)
        start_message_id = messages.first[:message_id] if random

        summary = if messages.empty?
          "_silence_"
        else
          conversation, _message_count = summarize_messages(messages)
          "**#{call_open_ai(conversation)}**"
        end

        if start_message_id.present?
          link = "https://discord.com/channels/#{event.server.id}/#{event.channel.id}/#{start_message_id}"
          responses << "* #{start_time.strftime("%B %d, %Y")}: #{summary} #{link}"
        else
          responses << "* #{start_time.strftime("%B %d")}: #{summary}"
        end

        end_time = start_time
        start_time = start_of_day(day + 2)
      end

      responses.reverse.join("\n")
    end
  end

  private

  def call_open_ai(conversation)
    OpenaiClient.chat(
      "You must return a single word, no formatting or spacing or explanation, just one word. Your task is to look at the following conversation and assign one word to it as a summary or to capture the theme or emotion of that conversation. It is a conversation in a casual chat between friends. Try to be clever about what that word is, be interesting or creative. The conversation you need to summarize in one word is:\n\n#{conversation}\n",
      model: "gpt-5-mini"
    ).first
  end
end
