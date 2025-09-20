# frozen_string_literal: true

class InsultCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "Who should I quacking insult?"
    elsif rand < 0.05 && user.mandate_name
      OpenaiClient.chat(insult_person_prompt(user.mandate_name)).first.strip
    else
      OpenaiClient.chat(insult_prompt(query)).first.strip
    end
  end

  private

  def insult_prompt(text)
    "Write a biting and witty insult directed at #{scrub(text)}."
  end

  def insult_person_prompt(name)
    "Write a biting and witty insult directed at #{scrub(name)}, making it clear that you do not care for their attitude."
  end

  def scrub(text)
    text.strip.gsub(/^about /i, "")
  end
end
