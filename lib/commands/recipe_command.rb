# frozen_string_literal: true
class RecipeCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    if query.blank?
      "What kind of recipe?"
    else
      OpenaiClient.completion(prompt(query), openai_params).first.strip
    end
  end

  private

  def prompt(text)
    x = "Write a recipe for \"#{ text.strip }\" appearing in #{ publication }"
    puts x
    x
  end

  def publication
    [
      "Bon Appetit",
      "Cook's Illustrated",
      "Modernist Cuisine",
      "Betty Crocker’s Cookbook",
    ].sample
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
