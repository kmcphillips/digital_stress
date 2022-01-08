# frozen_string_literal: true
class OpenaiCommand < BaseSubcommand
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
    }.freeze
  end

  private

  def imagine
    ImagineCommand.new(event: event, bot: bot, params: params.dup.drop(1)).response
  end

  def instruct
    if query.blank?
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

      OpenaiClient.completion(query.strip, openai_params)
    end
  end
end
