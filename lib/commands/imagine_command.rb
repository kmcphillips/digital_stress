# frozen_string_literal: true
class ImagineCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-imagine something"
    else
      OpenaiData.completion(promp(text), max_tokens: rand(70..100))
    end
  end

  private

  def prompt(text)
    "This is an exercise in creativity. I'll give you an example, and you'll tell me a creative short story based on that example.

    Example: #{ text }
    Story: "
  end
end
