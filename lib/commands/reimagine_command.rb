# frozen_string_literal: true
class ReimagineCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Quacking-imagine something"
    else
      text = OpenaiClient.completion(text_prompt, openai_params).first.strip
      file = Dreamstudio.image_file(text)
      event.send_file(file, filename: "reimagine.png") if file
      text
    end
  end

  private

  def text_prompt
    "In a couple of sentences, describe in visual detail an image of #{ scrubbed_query }."
  end

  def scrubbed_query
    query.strip.gsub(/[.!?:;]\Z/, "")
  end

  def openai_params
    {
      engine: OpenaiClient.default_engine,
      max_tokens: rand(200..400),
      temperature: 0.8,
      top_p: 1.0,
      frequency_penalty: 1.8,
      presence_penalty: 0.4,
    }
  end
end
