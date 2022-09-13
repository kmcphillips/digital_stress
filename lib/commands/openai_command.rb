# frozen_string_literal: true
class OpenaiCommand < BaseSubcommand
  include AfterRecorderStrikethroughAgainable

  CHANNELS = [
    "mandatemandate#general",
    "mandatemandate#quigital",
    "duck-bot-test#testing",
  ].freeze

  def channels
    CHANNELS
  end

  def subcommands
    {
      imagine: "Tell it to imagine something",
      instruct: "Instruct it to return something",
      image: "Generate an image with Stability AI",
    }.freeze
  end

  private

  def imagine
    ImagineCommand.new(event: event, bot: bot, params: params.dup.drop(1)).response
  end

  def instruct
    if subcommand_query.blank?
      "Quack! Instruct something."
    else
      openai_params = {
        engine: "davinci-instruct-beta-v3",
        max_tokens: 300,
        temperature: 0.8,
        top_p: 1.0,
        frequency_penalty: 0.4,
        presence_penalty: 0.4,
      }

      OpenaiClient.completion(subcommand_query.strip, openai_params)
    end
  end

  def image
    if subcommand_query.blank?
      "Quack! What do you want an image of?"
    else
      artifact = Dreamstudio.generate_image(prompt: subcommand_query)

      if artifact
        Tempfile.create(["stability-ai-artifact-image", ".png"], binmode: true) do |file|
          file.write(artifact.binary)
          file.rewind

          event.send_file(file, filename: "stability-ai.png")
        end
      else
        "Quack! Got no image back??"
      end
    end
  end
end
