# frozen_string_literal: true

module AfterRecorderStrikethroughAgainable
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
        subcommand: respond_to?(:subcommand, true) ? subcommand : nil,
        redaction_action: :strikethrough
      )
    end
  end
end

module AfterRecorderRedactAgainable
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
        subcommand: respond_to?(:subcommand, true) ? subcommand : nil,
        redaction_action: :redact
      )
    end
  end
end
