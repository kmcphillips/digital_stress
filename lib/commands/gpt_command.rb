# frozen_string_literal: true

class GptCommand < BaseCommand
  def response
    if query.blank?
      "Quack! Gotta say something."
    else
      response, @response_id = OpenaiClient.responses(query)
      response
    end
  end

  def after(message:)
    Recorder.set_message_metadata(message.id, :openai_gpt_response_id, @response_id) if defined?(@response_id) && @response_id.present?
  end
end
