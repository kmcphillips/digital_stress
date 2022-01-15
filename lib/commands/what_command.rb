# frozen_string_literal: true
class WhatCommand < BaseCommand
  def response
    if query.present? && query.match(/think/) # what do you think?
      recent = recent_conversation

      if recent.blank?
        "What are we talking about?"
      else
        OpenaiClient.completion(prompt(recent), openai_params)
      end
    else
      "What?"
    end
  end

  private

  def recent_conversation
    Recorder.recent(server: server, channel: channel)
      .to_a.reverse
      .map { |r| "#{ r[:username] }: #{ r[:message] }" }
      .join("\n")
  end

  def prompt(recent)
    "In a couple sentences, give a strong and funny opinion on the following conversation:\n#{ recent.strip }"
  end

  def openai_params
    {
      engine: "davinci-instruct-beta-v3",
      max_tokens: rand(120..256),
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 1.8,
      presence_penalty: 0.4,
    }
  end
end
