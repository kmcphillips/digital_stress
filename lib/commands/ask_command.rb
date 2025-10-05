# frozen_string_literal: true

class AskCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "What do you want to know?"
    elsif attached_images.many?
      "Quack! Only one image at a time please."
    else
      message, citations = PerplexityClient.chat(query, image_url: attached_images.first&.url)
      @citations = citations
      message
    end
  end

  def after(message:)
    if defined?(@citations) && @citations.present?
      flags = (1 << 2) # SUPPRESS_EMBEDS
      citations_message = @citations.each_with_index.map { |citation, index| "[#{index + 1}](#{citation})" }.join(", ")
      message.reply!("(Citations #{citations_message})", flags: flags) if citations_message.present?
    end
  end
end
