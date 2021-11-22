# frozen_string_literal: true
class QuigitalCommand < BaseSubcommand
  def subcommands
    {
      stats: "Show some stats from quigital.com.",
    }.freeze
  end

  def channels
    [
      "mandatemandate#general",
      "mandatemandate#quigital",
      "duck-bot-test#testing",
    ]
  end

  private

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
