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
      chat: "Chat with OpenAI GPT-5",
      instruct: "Chat with OpenAI GPT-5",
      image: "Generate an image with OpenAI Dall-E 2",
      imagine: "Tell it to imagine something",
      reimagine: "Tell it to imagine an image of something",
      duck: "Toggle AI generated Duck responses",
      question: "Respond to a question with the fine tuned OpenAI GPT-3 model"
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
      "Quack! Gotta say something."
    elsif attached_images.many?
      "Quack! Only one image at a time is supported."
    else
      OpenaiClient.chat(subcommand_query.strip, image_url: attached_images.first&.url)
    end
  end

  def image
    if subcommand_query.blank?
      "Quack! What do you want an image of?"
    else
      OpenaiClient.image_file(subcommand_query.strip).first || "Quack! Failed to generate an image."
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

  def duck
    if Flags.active?("duck_generated", server: server)
      Flags.deactivate("duck_generated", server: server)
      ":speech_balloon: Quack! Duck responses are now **learned** responses only."
    else
      Flags.activate("duck_generated", server: server)
      ":speech_balloon: Quack! Duck responses are now **AI generated**."
    end
  end

  def chat
    instruct
  end
end
