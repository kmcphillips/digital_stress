# frozen_string_literal: true

class GptResponder < BaseResponder
  def respond
    if event.message.reply?
      previous_message_id = event.message.referenced_message.id
      previous_response_id = Recorder.get_message_metadata(previous_message_id, :openai_gpt_response_id)

      # Only respond if it's part of a conversation that was recorded
      if previous_response_id.present?
        while_typing do
          response, response_id = OpenaiClient.responses(text, previous_response_id: previous_response_id)

          if Formatter.too_long?(response)
            Global.logger.warn("[GptResponder] response of length #{response.length} is too long #{response}")
            response = Formatter.truncate_too_long(response)
          end

          new_message = event.respond(response)
          Recorder.set_message_metadata(new_message.id, :openai_gpt_response_id, response_id)
        end
      end
    end
  end
end
