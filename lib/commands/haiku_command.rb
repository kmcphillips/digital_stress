# frozen_string_literal: true

class HaikuCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "*Your input is blank\nI can't compose from nothing\nTry again quack quack*"
    else
      text = OpenaiClient.chat(text_prompt(query)).first.strip
      file = OpenaiClient.image_file(image_prompt(text)).first
      event.send_file(file, filename: "haiku.png") if file
      "*#{text}*"
    end
  end

  private

  def text_prompt(text)
    "Compose a haiku about #{text.strip.gsub(/[.!?:;]\Z/, "")}."
  end

  def image_prompt(text)
    "A traditional style Japanese painting depicting the following haiku:\n#{text}"
  end
end
