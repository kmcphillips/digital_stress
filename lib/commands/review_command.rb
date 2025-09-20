# frozen_string_literal: true

class ReviewCommand < BaseCommand
  include AfterRecorderStrikethroughAgainable

  def response
    OpenaiClient.chat(prompt(query)).first.strip
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
end
