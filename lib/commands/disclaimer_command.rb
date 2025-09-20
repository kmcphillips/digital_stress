# frozen_string_literal: true

class DisclaimerCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.chat(prompt).first.strip
  end

  private

  def prompt
    "Write a fine-print disclaimer insulating yourself from liability in the event that a long string of bizarre, nonsensical things happen. Be specific about these things."
  end
end
