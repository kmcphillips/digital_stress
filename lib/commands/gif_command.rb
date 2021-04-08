# frozen_string_literal: true
class GifCommand < BaseCommand
  def response
    if query.blank?
      "Quacking-search for something"
    else
      Dedup.new("Gif", event.server&.name, event.channel&.name).list(Gif.search_urls(query)) || "Quack-all found"
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
