# frozen_string_literal: true

class WhatCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.present? && query.match(/think/) # what do you think?
      if !Recorder.record_channel?(server: server, channel: channel)
        "Quack, sorry. I'm not following what's happening in this channel."
      elsif recent_conversation.blank?
        "Quack? What are we talking about? Doesn't look like much."
      else
        OpenaiClient.completion(prompt, openai_params)
      end
    else
      "What?"
    end
  end

  private

  def recent_conversation
    Recorder.recent(server: server, channel: channel, time_offset: 2.hours)
      .to_a.reverse
      .map { |r| "#{r[:username]}: #{r[:message]}" }
      .join("\n")
  end

  def prompt
    "In two or three detailed sentences sentences, give #{tone} opinion on the following conversation:\n#{recent_conversation.strip}"
  end

  def tone
    [
      "a funny",
      "an extremely sarcastic",
      "a funny and strongly worded",
      "a very negative",
      "a very enthusiastic and happy",
      "a highly critical",
      "a sarcastic and negative",
      "a confused",
      "a sarcastic and excited"
    ].sample
  end

  def openai_params
    {
      model: OpenaiClient.default_model,
      max_tokens: rand(120..256),
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 1.8,
      presence_penalty: 0.4
    }
  end
end
