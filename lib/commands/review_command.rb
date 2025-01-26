# frozen_string_literal: true

class ReviewCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.completion(prompt(query), openai_params).first.strip
  end

  private

  def prompt(product_idea)
    sentiment = ["positive", "negative"].sample
    conclusion = ["creepy", "weird", "nonsensical"].sample

    if product_idea.present?
      "Write a #{sentiment} review for \"#{product_idea}\". Explain your opinion in relation to the product's core features and how they do or do not fit into your life. Give it a star rating, but instead of stars, use an object related to \"#{product_idea}\", Conclude your review with something a little #{conclusion} and off-topic."
    else
      "Write a #{sentiment} review for a consumer product. Explain your opinion in relation to the product's core features and how they do or do not fit into your life. Give it a star rating, but instead of stars, use an object related to the product, Conclude your review with something a little #{conclusion} and off-topic."
    end
  end

  def openai_params
    {
      model: OpenaiClient.default_model,
      max_tokens: 256,
      temperature: 1.0,
      top_p: 1.0,
      frequency_penalty: 0.0,
      presence_penalty: 0.0
    }
  end
end
