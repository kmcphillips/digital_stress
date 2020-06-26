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
require_relative "lib/datastore"
LegacyDatastore = Datastore.new(db_file)
DB = Sequel.sqlite(db_file)

require_relative "lib/key_value_store"
KV = KeyValueStore.new(DB.opts[:database]) # ENV["REDIS_URL"]

require_relative "lib/dedup"
require_relative "lib/steam"
require_relative "lib/azure"
require_relative "lib/gif"
require_relative "lib/user"
require_relative "lib/recorder"
require_relative "lib/learner"
require_relative "lib/web_duck"

require_relative "lib/base_command"
require_relative "lib/base_subcommand"
require_relative "lib/ping_command"
require_relative "lib/games_command"
require_relative "lib/gif_command"
require_relative "lib/image_command"
require_relative "lib/status_command"
require_relative "lib/steam_command"
require_relative "lib/learn_command"
require_relative "lib/deploy_command"

require_relative "lib/base_responder"
require_relative "lib/simple_responder"
require_relative "lib/t_minus"
require_relative "lib/alchemy"
require_relative "lib/google_image_search_responder"

require_relative "lib/duck"
