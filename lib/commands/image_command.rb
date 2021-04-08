# frozen_string_literal: true
class ImageCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for something"
    else
      Dedup.new("Azure.image", event.server&.name, event.channel&.name, query.strip).list(Azure.search_image_urls(query)) || "Quack-all found"
    end
  end

  def after(message)
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
