# frozen_string_literal: true

class MonopolyCommand < BaseCommand
  include AfterRecorderRedactAgainable

  def response
    if query.blank?
      "Quack! This isn't free parking. What do you want the card to be about?"
    else
      file = OpenaiClient.image_file(image_prompt(query)).first
      event.send_file(file, filename: "monopoly.png") if file
      nil
    end
  end

  private

  def image_prompt(text)
    "Make a Chance or Community Chest card from Monopoly about #{text.strip}. It should be a simple black text and black line drawing, in the style of Monopoly, over either the yellow or orange background. It should look like a card from the game. The Monopoly guy should be present doing an appropriate action. Make it unhinged and funny."
  end
end
