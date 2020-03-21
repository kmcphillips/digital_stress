# frozen_string_literal: true
require "pry"
require "active_support/all"
require "dotenv/load"
require "discordrb"
require "logger"
require "sqlite3"
require "httparty"
require "nokogiri"
require "time_difference"
require "securerandom"
require "lightly"

logger_file = File.open("bot.log", File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
Log = Logger.new(logger_file)
Log.level = Logger::INFO

require_relative "lib/dedup"
require_relative "lib/steam"
require_relative "lib/azure"
require_relative "lib/gif"

require_relative "lib/datastore"
require_relative "lib/recorder"

require_relative "lib/base_command"
require_relative "lib/base_subcommand"
require_relative "lib/ping_command"
require_relative "lib/games_command"
require_relative "lib/gif_command"
require_relative "lib/image_command"
require_relative "lib/status_command"
require_relative "lib/steam_command"

require_relative "lib/base_responder"
require_relative "lib/simple_responder"
require_relative "lib/t_minus"
require_relative "lib/alchemy"

require_relative "lib/duck"
