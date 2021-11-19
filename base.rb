# frozen_string_literal: true
require "pry"
require "active_support/all"
require "config"
require "discordrb"
require "logger"
require "redis"
require "sqlite3"
require "sequel"
require "httparty"
require "nokogiri"
require "time_difference"
require "securerandom"
require "sinatra/base"
require "systemcall"
require "tempfile"
require "fileutils"
require "open3"
require "twilio-ruby"
require "wikipedia"
require "games_dice"
require "ruby/openai"
require "fuzzy_match"

require_relative "lib/global"

Global.environment[:config] ||= Global.root.join("config/config.yml")
Global.environment[:log] ||=  Global.root.join("bot.log")
Global.environment[:db_file] ||= Global.root.join("chat.sqlite3")
Global.environment[:kv] ||= Global.root.join("chat.sqlite3")

Config.setup do |config|
  config.const_name = 'IgnoreMeGlobalConfiguration'
  config.evaluate_erb_in_yaml = false
end
Config.load_and_set_settings(Global.environment[:config])
Global.config = IgnoreMeGlobalConfiguration # Can't tell rubyconfig to not export a `const_name` so we just ignore it and pass it through

logger_file = File.open(Global.environment[:log], File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
Global.logger = Logger.new(logger_file, level: (Global.config.discord.debug_log ? Logger::DEBUG : Logger::INFO))
Discordrb::LOGGER.streams << logger_file if Global.config.discord.debug_log

Global.db = Sequel.sqlite(Global.environment[:db_file].to_s)

require_relative "lib/persistence/key_value_store"
Global.kv = KeyValueStore.new(Global.environment[:kv].to_s) # Global.config.redis.url

Global.openai_client = OpenAI::Client.new(access_token: Global.config.openai.access_token)

require_relative "lib/persistence/recorder"
require_relative "lib/persistence/learner"
require_relative "lib/persistence/flags"
require_relative "lib/persistence/openai_data"
require_relative "lib/persistence/dnd_5e_data"
require_relative "lib/persistence/dnd_5e_parser"

require_relative "lib/util/pinger"
require_relative "lib/util/formatter"
require_relative "lib/util/dedup"
require_relative "lib/util/quacker"

require_relative "lib/models/user"
require_relative "lib/mandate_user_refinements"
require_relative "lib/models/announcement"

require_relative "lib/clients/steam"
require_relative "lib/clients/azure"
require_relative "lib/clients/gif"
require_relative "lib/clients/wolfram_alpha"
require_relative "lib/clients/texter"
require_relative "lib/clients/wikipedia_client"

require_relative "lib/base_command"
require_relative "lib/base_subcommand"

require_relative "lib/commands/ping_command"
require_relative "lib/commands/games_command"
require_relative "lib/commands/gif_command"
require_relative "lib/commands/image_command"
require_relative "lib/commands/status_command"
require_relative "lib/commands/steam_command"
require_relative "lib/commands/learn_command"
require_relative "lib/commands/deploy_command"
require_relative "lib/commands/toggle_the_record_command"
require_relative "lib/commands/off_the_record_command"
require_relative "lib/commands/on_the_record_command"
require_relative "lib/commands/wolfram_alpha_command"
require_relative "lib/commands/chat_command"
require_relative "lib/commands/train_command"
require_relative "lib/commands/text_command"
require_relative "lib/commands/alchemy_command"
require_relative "lib/commands/wikipedia_command"
require_relative "lib/commands/again_command"
require_relative "lib/commands/abort_command"
require_relative "lib/commands/announcement_command"
require_relative "lib/commands/roll_command"
require_relative "lib/commands/openai_command"
require_relative "lib/commands/imagine_command"
require_relative "lib/commands/dnd_command"
require_relative "lib/commands/notifications_command"

require_relative "lib/responders/concerns/responder_matcher"
require_relative "lib/responders/base_responder"
require_relative "lib/responders/simple_responder"
require_relative "lib/responders/t_minus_responder"
require_relative "lib/responders/alchemy_responder"
require_relative "lib/responders/google_image_search_responder"
require_relative "lib/responders/temperature_responder"
require_relative "lib/responders/topic_responder"
require_relative "lib/responders/openai_classifications_responder"

require_relative "lib/tasks/task_base"
require_relative "lib/tasks/daily_announcements"

require_relative "lib/web_duck"
require_relative "lib/duck"

Dnd5eData.load
