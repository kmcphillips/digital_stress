# frozen_string_literal: true

class DefineCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Define what?"
    elsif rand < 0.2 && user.mandate_name
      OpenaiClient.chat(wrong_prompt(query)).first.strip
    else
      OpenaiClient.chat(prompt(query)).first.strip
    end
  end

  private

  def prompt(text)
    "Give the definition of: #{text.strip}"
  end

  def wrong_prompt(text)
    "Give an amusing but incorrect definition of: #{text.strip}"
  end
end
