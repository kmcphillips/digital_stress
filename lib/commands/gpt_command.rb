# frozen_string_literal: true

class GptCommand < BaseCommand
  def response
    if query.blank?
      "Quack! Gotta say something."
    else
      if attached_images.any?
        if attached_images.one?
          response, @response_id = OpenaiClient.responses(query, image_url: attached_images.first.url)
        else
          "Quack! Only one image at a time please."
        end
      else
        response, @response_id = OpenaiClient.responses(query)
      end

      response
    end
  end

  def after(message:)
    Recorder.set_message_metadata(message.id, :openai_gpt_response_id, @response_id) if defined?(@response_id) && @response_id.present?
  end
end
