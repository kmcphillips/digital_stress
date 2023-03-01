# frozen_string_literal: true
class AiResponder < BaseResponder
  include ResponderMatcher

  def respond
    respond_match(/kitchen.?noise/i) do
      completion("Play a popular song using only kitchen noises.")
    end

    respond_match(/\?\Z/i, chance: 0.05) do
      key = "ai_responder_question:#{ server }:#{ channel }"

      if !Global.kv.read(key).present? # TODO: this could be promoted into a `frequency:` option that does kv read/write
        Global.kv.write(key, Time.now.to_i.to_s, ttl: 5.minutes)
        start_typing

        name, completion = MandateModels.question(text, name: guess_names_from_text(text).sample)

        "> **#{ name.capitalize }**: #{ completion.gsub("\n", "\n> ") }"
      end
    end
  end

  private

  def completion(prompt)
    OpenaiClient.completion(prompt, openai_params).first.strip
  end

  def openai_params
    {
      model: OpenaiClient.default_model,
      max_tokens: 256,
      temperature: 1.0,
      top_p: 1.0,
      frequency_penalty: 0.0,
      presence_penalty: 0.0,
    }
  end

  def guess_names_from_text(input)
    MandateModels::QUESTION_MODELS.keys.map do |name|
      name if input.downcase.include?(name)
    end.compact
  end
end
