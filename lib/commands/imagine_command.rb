# frozen_string_literal: true
class ImagineCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-imagine something"
    else
      response = Global.openai_client.completions(engine: "davinci", parameters: { prompt: query, max_tokens: 40 })
      response.parsed_response['choices'].map{ |c| c["text"] }
    end
  end
end
