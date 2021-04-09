# frozen_string_literal: true
require_relative "base"

def run_bot
  Global.bot = Discordrb::Bot.new(token: Global.config.discord.token)
  Global.bot.run(true)
end

# The `Global` class has access to database, kv store, config, log, etc.
# Do > run_bot

binding.pry
