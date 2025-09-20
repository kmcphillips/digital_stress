# frozen_string_literal: true

class ReimagineCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Quacking-imagine something"
    else
      text = OpenaiClient.chat(text_prompt).first.strip
      file = OpenaiClient.image_file(text).first
      event.send_file(file, filename: "reimagine.png") if file
      text
    end
  end

  private

  def text_prompt
    "In a couple of sentences, describe in visual detail an image of #{scrubbed_query}."
  end

  def scrubbed_query
    query.strip.gsub(/[.!?:;]\Z/, "")
  end
end
