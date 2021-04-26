# frozen_string_literal: true
require_relative "base"

def run_bot
  if !Global.bot
    Global.bot = Discordrb::Bot.new(token: Global.config.discord.token)
    Global.bot.run(true)
  end
  !!Global.bot
end

def test_channel
  run_bot
  Pinger.find_channel(server: 'duck-bot-test', channel: 'testing')
end

# The `Global` class has access to database, kv store, config, log, etc.
# To connect to bot: run_bot
# For the test channel: test_channel

binding.pry
