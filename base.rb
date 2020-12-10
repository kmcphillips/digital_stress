# frozen_string_literal: true
require "pry"
require "active_support/all"
require "dotenv/load"
require "discordrb"
require "logger"
require "redis"
require "sqlite3"
require "sequel"
require "httparty"
require "nokogiri"
require "time_difference"
require "securerandom"
require "lightly"
require "sinatra/base"

logger_file = File.open("bot.log", File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
Log = Logger.new(logger_file)
Log.level = Logger::INFO

db_file = File.join(File.dirname(__FILE__), "chat.sqlite3")
DB = Sequel.sqlite(db_file)

require_relative "lib/key_value_store"
KV = KeyValueStore.new(DB.opts[:database]) # ENV["REDIS_URL"]

require_relative "lib/util/pinger"
require_relative "lib/util/formatter"
require_relative "lib/util/dedup"

require_relative "lib/user"
require_relative "lib/recorder"
require_relative "lib/learner"
require_relative "lib/web_duck"

require_relative "lib/clients/steam"
require_relative "lib/clients/azure"
require_relative "lib/clients/gif"
require_relative "lib/clients/wolfram_alpha"

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
require_relative "lib/commands/off_the_record_command"
require_relative "lib/commands/wolfram_alpha_command"
require_relative "lib/commands/chat_command"

require_relative "lib/responders/base_responder"
require_relative "lib/responders/simple_responder"
require_relative "lib/responders/t_minus_responder"
require_relative "lib/responders/alchemy_responder"
require_relative "lib/responders/google_image_search_responder"
require_relative "lib/responders/temperature_responder"

require_relative "lib/duck"
