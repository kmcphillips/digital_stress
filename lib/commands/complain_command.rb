# frozen_string_literal: true

class ComplainCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.chat(prompt(query)).first.strip
  end

  private

  def prompt(text)
    if text.blank?
      "Humorously complain about a bizarre, gross, nonsensical problem, but give it a positive spin at the very end."
    else
      text = "about #{text.strip}" unless text.strip.downcase.start_with?("about")
      "Humorously complain #{text}, but give it a positive spin at the very end."
    end
  end
end
