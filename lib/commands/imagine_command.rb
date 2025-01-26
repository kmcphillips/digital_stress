# frozen_string_literal: true

class ImagineCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Quacking-imagine something"
    else
      file = nil

      thread = Thread.new do
        file = OpenaiClient.image_file("#{scrubbed_query} #{style}").first
      end

      text = OpenaiClient.completion(prompt, openai_params)

      thread.join

      event.send_file(file, filename: "imagine.png") if file
      text
    end
  end

  private

  def prompt
    "In a couple sentences, describe #{tone} what #{scrubbed_query} would be like."
  end

  def scrubbed_query
    query.strip.gsub(/[.!?:;]\Z/, "")
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

  def tone
    [
      "in a sarcastic tone",
      "in an exaggerated tone",
      "in a funny and sarcastic way",
      "using big words",
      "in an excited way",
      "enthusiastically",
      "critically"
    ].sample
  end

  def style
    [
      "pencil sketch",
      "watercolor",
      "oil on canvas",
      "pastel",
      "digital art",
      "photograph",
      "epic lighting",
      "cell shaded",
      "pixel art",
      "vector art",
      "3D rendering",
      "product shot",
      "retro style",
      "new yorker cartoon"
    ].sample
  end
end
