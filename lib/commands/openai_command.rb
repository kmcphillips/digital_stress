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
      models = {
        "dave" => "davinci:ft-quigital:dave-2023-03-01-02-04-08",
        "eliot" => "davinci:ft-quigital:eliot-2023-03-01-04-52-36",
        "kevin" => "davinci:ft-quigital:kevin-2023-03-01-00-22-22",
        "patrick" => "davinci:ft-quigital:patrick-2023-03-01-03-43-38",
      }

      name = subcommand_query.strip.split(" ").first.downcase
      if models[name]
        prompt = subcommand_query.strip.gsub(/\A[a-zA-Z] /, "")
      else
        name = models.keys.sample
        prompt = subcommand_query.strip
      end
      prompt = "#{ prompt }\n\n###\n\n"

      openai_params = {
        model: models[name],
        max_tokens: 256,
        temperature: 0.8,
        top_p: 1.0,
        frequency_penalty: 0.2,
        presence_penalty: 0.0,
        stop: [ "###" ],
      }

      result = OpenaiClient.completion(prompt, openai_params)
      completion = result.first.gsub("###", "").strip

      "> **#{ name.capitalize }**: #{ completion }"
    end
  end
end
