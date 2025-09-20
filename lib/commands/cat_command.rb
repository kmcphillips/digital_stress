# frozen_string_literal: true

class CatCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.chat("Write a short, humorous monologue about cat problems using only cat sounds.").first.strip
  end
end
