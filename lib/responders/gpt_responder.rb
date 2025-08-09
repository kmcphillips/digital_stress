# frozen_string_literal: true

class GptResponder < BaseResponder
  def respond
    if event.message.reply?
      previous_message_id = event.message.referenced_message.id
      previous_response_id = Recorder.get_message_metadata(previous_message_id, :openai_gpt_response_id)

      # Only respond if it's part of a conversation that was recorded
      if previous_response_id.present?
        response, response_id = nil, nil

        while_typing do
          if attached_images.any?
            if attached_images.one?
              response, response_id = OpenaiClient.responses(text, previous_response_id: previous_response_id, image_url: attached_images.first.url)
            else
              "Quack! Only one image at a time please."
            end
          else
            response, response_id = OpenaiClient.responses(text, previous_response_id: previous_response_id)
          end
        end

        if Formatter.too_long?(response)
          Global.logger.warn("[GptResponder] response of length #{response.length} is too long #{response}")
          response = Formatter.truncate_too_long(response)
        end

        new_message = event.respond(response) if response.present?
        Recorder.set_message_metadata(new_message.id, :openai_gpt_response_id, response_id) if response_id.present?
      end
    end
  end
end
