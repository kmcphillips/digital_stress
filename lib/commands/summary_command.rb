# frozen_string_literal: true
class SummaryCommand < BaseCommand
  def response
    if event.channel.pm?
      "Quack, I can't summarize a direct message."
    elsif !Recorder.record_channel?(server: server, channel: channel)
      "Quack, I can't provide a summary of a channel I am not recording."
    else
      messages = Recorder.all_since(server: server, channel: channel, since: start_of_day)

      if messages.empty?
        "Quack, no messages since start of day. (#{ start_of_day })"
      else
        conversation = ""
        message_count = 0

        messages.each do |message|
          name = User.from_id(message[:user_id], server: server)&.mandate_display_name.presence || message[:username]
          message_text = "#{ name }: #{ message[:message] }"

          if conversation.split.size + message_text.split.size > max_length_in_words
            break
          else
            message_count += 1
            conversation = "#{ message_text }\n#{ conversation }"
          end
        end

        summary = call_open_ai(conversation)

        if message_count == messages.count
          "#{ summary } _(Summary of all #{ message_count } messages today)_"
        else
          "#{ summary } _(Summary of #{ message_count } messages)_"
        end
      end
    end
  end

  private

  def max_length_in_words
    1400
  end

  def start_of_day
    current_time = Time.now.utc
    result = Time.new(
      current_time.year,
      current_time.month,
      current_time.day,
      8, 0, 0, "UTC" # 8AM UTC is 3AM/4AM EST/EDT
    )
    result = result - 1.day if result > current_time
    result
  end

  def call_open_ai(conversation)
    openai_params = {
      temperature: 0.7,
      max_tokens: 200,
      top_p: 1.0,
      frequency_penalty: 0.0,
      presence_penalty: 1
    }
    prompt = "Provide a summary of this chat conversation:\n\n#{ conversation }\n\n"

    OpenaiClient.chat(prompt, openai_params).first
  end
end
