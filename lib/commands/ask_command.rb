# frozen_string_literal: true
class AskCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "What do you want to know?"
    else
      PerplexityClient.chat(query)
    end
  end
end
