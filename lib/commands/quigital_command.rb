# frozen_string_literal: true
class QuigitalCommand < BaseSubcommand
  def subcommands
    {
      stats: "Show some stats from quigital.com.",
      say: "Say something with Quigital's voice.",
    }.freeze
  end

  def channels
    [
      "mandatemandate#general",
      "mandatemandate#quigital",
      "mandatemandate#websites",
      "duck-bot-test#testing",
    ]
  end

  private

  def say
    if query.blank?
      "Quack? Nothing to say."
    else
      file = AwsClient.polly_say(subcommand_query)
      event.send_file(file, filename: "quigital.mp3")
      nil
    end
  end

  def stats
    response = HTTParty.get(stats_url)

    if !response.success?
      Global.logger.error("Qugital stats returned HTTP #{ response.code }")
      Global.logger.error(response.body)

      ":bangbang: Quack failed to reach Quigital!"
    else
      emoji = Pinger.find_emoji("quigital", server: server)
      lines = [
        "#{ emoji || '' } Stats!",
      ]

      response.each do |key, value|
        lines << "* #{ key.titleize }: **#{ value }**"
      end

      lines.join("\n")
    end
  end

  def stats_url
    "https://quigital.com/api/stats.json?api_key=#{ api_key }"
  end

  def api_key
    Global.config.duck.api_key
  end
end
