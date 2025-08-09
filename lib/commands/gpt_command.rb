# frozen_string_literal: true

class GptCommand < BaseCommand
  def response
    if query.blank?
      "Quack! Gotta say something."
    elsif attached_images.many?
      "Quack! Only one image at a time please."
    else
      response, @response_id = OpenaiClient.responses(query, image_url: attached_images.first&.url)
      response
    end
  end

  def after(message:)
    Recorder.set_message_metadata(message.id, :openai_gpt_response_id, @response_id) if defined?(@response_id) && @response_id.present?
  end
end
