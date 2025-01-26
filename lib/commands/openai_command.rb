# frozen_string_literal: true

class OpenaiCommand < BaseSubcommand
  include AfterRecorderStrikethroughAgainable

  CHANNELS = [
    "mandatemandate",
    "duck-bot-test"
  ].freeze

  def channels
    CHANNELS
  end

  def subcommands
    {
      imagine: "Tell it to imagine something",
      reimagine: "Tell it to imagine an image of something",
      instruct: "Instruct it to return something",
      image: "Generate an image with OpenAI Dall-E 2",
      question: "Respond to a question with the fine tuned OpenAI GPT-3 model",
      chat: "Chat with the fine tuned OpenAI GPT-3 model"
    }.freeze
  end

  private

  def imagine
    ImagineCommand.new(event: event, bot: bot, params: params.dup.drop(1)).response
  end

  def reimagine
    ReimagineCommand.new(event: event, bot: bot, params: params.dup.drop(1)).response
  end

  def instruct
    if subcommand_query.blank?
      "Quack! Instruct something."
    else
      openai_params = {
        model: OpenaiClient.default_model,
        max_tokens: 300,
        temperature: 0.8,
        top_p: 1.0,
        frequency_penalty: 0.4,
        presence_penalty: 0.4
      }

      OpenaiClient.completion(subcommand_query.strip, openai_params)
    end
  end

  def image
    if subcommand_query.blank?
      "Quack! What do you want an image of?"
    else
      OpenaiClient.image(subcommand_query.strip).first || "Quack! Failed to get a response from DALL-E."
    end
  end

  def question
    if subcommand_query.blank?
      "Quack! What do you want to ask?"
    elsif !subcommand_query.ends_with?("?")
      "Quack! Is that a question??"
    else
      name = subcommand_query.strip.split(" ").first.gsub(/[^a-zA-Z]/, "")

      if MandateModels.question_model_for(name)
        prompt = subcommand_query.strip.gsub(/\A[a-zA-Z] /, "")
      else
        name = MandateModels::QUESTION_MODELS.keys.sample
        prompt = subcommand_query.strip
      end
      prompt = "#{prompt}\n\n###\n\n"

      name, completion = MandateModels.question(prompt, name: name)

      if completion.present?
        "> **#{name.capitalize}**: #{completion.gsub("\n", "\n> ")}"
      else
        "Quack! Got a blank result for some reason."
      end
    end
  end

  def chat
    if subcommand_query.blank?
      "Quack! Chat as who?"
    else
      name, completion = MandateModels.chat("", name: subcommand_query.strip.split(" ").first.gsub(/[^a-zA-Z]/, ""))

      if completion.present?
        "> **#{name.capitalize}**: #{completion.gsub("\n", "\n> ")}"
      else
        "Quack! Got a blank result for some reason."
      end
    end
  end
end
