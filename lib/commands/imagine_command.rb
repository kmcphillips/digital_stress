# frozen_string_literal: true
class ImagineCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-imagine something"
    else
      response = Global.openai_client.completions(engine: "davinci", parameters: { prompt: prompt(query), max_tokens: rand(50..75) })
      result = response.parsed_response['choices'].map{ |c| c["text"] }
      raise "Got a blank result: #{ response.parsed_response }" if result.blank?
      result
    end
  end

  private

  def prompt(text)
    "This is an exercise in creativity. I'll give you an example, and you'll tell me a creative short story based on that example.

    Example: #{ text }
    Story: "
  end
end
