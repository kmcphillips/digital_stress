# frozen_string_literal: true
class NewCommand < BaseSubcommand
  include AfterRecorderStrikethroughAgainable

  def subcommands
    {
      game: "Create a new game with GPT-3",
    }.freeze
  end


  def game
    result = OpenaiClient.completion(game_prompt(query), openai_params).first.strip

    image_prompt = nil

    result = result.lines.map do |line|
      if matches = line.match(/\{(.+)\}/)
        image_prompt = matches[1].gsub(/ai image prompt:/i, "").strip

        nil
      else
        line
      end
    end.compact.join("\n")

    begin
      if image_prompt.present? && image_prompt.length > 10
        file = Dreamstudio.image_file(image_prompt)
        event.send_file(file, filename: "game.png") if file
      end
    rescue => e
      result = "#{ result }\n:bangbang: #{ e.message }"
    end

    result
  end

  private

  def game_prompt(text)
    about_fragment = if text.present?
      "be about #{ text.strip } and "
    else
      ""
    end

    review_sentiment = [ "positive", "negative", "mixed" ].sample

    "Think of an imaginary video game. The game should #{ about_fragment }have some bizarre or nonsensical elements, and at least four-player multiplayer. Tell me the name, tagline, and a one-sentence description of the game. Then tell me the price, platforms, and metacritic score. Then give a review for the game written in a #{ review_sentiment } tone. Then give me an AI image prompt for the box art of the game, wrapped in {}."
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
