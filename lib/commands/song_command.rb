# frozen_string_literal: true

class SongCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "What should we sing about?"
    else
      OpenaiClient.chat(prompt(query)).first.strip
    end
  end

  private

  def prompt(text)
    text = "about #{text.strip}" unless text.strip.downcase.start_with?("about")
    "Write the lyrics to the chorus of a hit song #{text.strip}."
  end
end
