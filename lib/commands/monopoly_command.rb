# frozen_string_literal: true

class MonopolyCommand < BaseCommand
  include AfterRecorderRedactAgainable

  def response
    if query.blank?
      "Quack! This isn't free parking. What do you want the card to be about?"
    else
      OpenaiClient.image_file(image_prompt(query), size: "1024x1024").first || "Quack! Failed to generate a card."
    end
  end

  private

  def image_prompt(text)
    "Make a Chance or Community Chest card from Monopoly about #{text.strip}. It should be a simple black text and black line drawing, in the style of Monopoly, over either the yellow or orange background. It should look like a card from the game. The Monopoly guy should be present doing an appropriate action. Make it unhinged and funny."
  end
end
