# frozen_string_literal: true
class OpenaiCommand < BaseSubcommand
  include AfterRecorderStrikethroughAgainable

  CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#quigital",
    "mandatemandate#apps",
    "duck-bot-test#testing",
  ].freeze

  def channels
    CHANNELS
  end

  def subcommands
    {
      imagine: "Tell it to imagine something",
      reimagine: "Tell it to imagine an image of something",
      instruct: "Instruct it to return something",
      dalle: "Generate an image with OpenAI Dall-E 2",
      sd: "Generate an image with Stability AI Stable Diffusion",
      image: "Generate an image with Stability AI Stable Diffusion",
      question: "Respond to a question with the fine tuned OpenAI GPT-3 model",
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
        presence_penalty: 0.4,
      }

      OpenaiClient.completion(subcommand_query.strip, openai_params)
    end
  end

  def dalle
    if subcommand_query.blank?
      "Quack! What do you want an image of?"
    else
      OpenaiClient.image(subcommand_query.strip).first
    end
  end

  def sd
    if subcommand_query.blank?
      "Quack! What do you want an image of?"
    else
      if file = Dreamstudio.image_file(subcommand_query)
        event.send_file(file, filename: "ai.png")
        nil
      else
        "Quack! Got no image back??"
      end
    end
  end

  def image
    sd
  end

  def question
    if subcommand_query.blank?
      "Quack! What do you want to ask?"
    elsif !subcommand_query.ends_with?("?")
      "Quack! Is that a question??"
    else
      if MandateModels.question_model_for(subcommand_query.strip.split(" ").first)
        name = subcommand_query.strip.split(" ").first.gsub(/[^a-zA-Z]/, "")
        prompt = subcommand_query.strip.gsub(/\A[a-zA-Z] /, "")
      else
        name = nil
        prompt = subcommand_query.strip
      end
      prompt = "#{ prompt }\n\n###\n\n"

      name, completion = MandateModels.question(prompt, name: name)

      "> **#{ name.capitalize }**: #{ completion.gsub("\n", "\n> ") }"
    end
  end
end
