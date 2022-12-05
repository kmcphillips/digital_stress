# frozen_string_literal: true
class RecipeCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "What kind of recipe?"
    else
      file = nil
      publication = publications.sample

      thread = Thread.new do
        file = Dreamstudio.image_file(image_prompt(query, publication: publication))
      end

      text = OpenaiClient.completion(text_prompt(query, publication: publication), openai_params).first.strip

      thread.join
      event.send_file(file, filename: "recipe.png") if file

      text
    end
  end

  private

  def text_prompt(text, publication:)
    "Write a recipe for \"#{ text.strip }\" appearing in #{ publication }"
  end

  def image_prompt(text, publication:)
    "Recipe book photo of \"#{ text.strip }\" as it would appear in #{ publication }"
  end

  def publications
    [
      "Bon Appetit",
      "Cook's Illustrated",
      "Modernist Cuisine",
      "Betty Crocker’s Cookbook",
    ]
  end

  def openai_params
    {
      model: OpenaiClient.default_model,
      max_tokens: 256,
      temperature: 1.0,
      top_p: 1.0,
      frequency_penalty: 0.0,
      presence_penalty: 0.0,
    }
  end
end
