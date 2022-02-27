# frozen_string_literal: true
module AfterRecorderAgainable
  def after(message:)
    if message
      Recorder.set_againable(
        command_class: self.class.name,
        query: query.strip,
        query_user_id: event.author.id,
        query_message_id: event.message.id,
        response_user_id: message.author.id,
        response_message_id: message.id,
        server: server,
        channel: channel,
      )
    end
  end
end
