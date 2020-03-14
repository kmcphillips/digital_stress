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

require_relative "subcommands"
require_relative "games_command"
require_relative "status_command"

require_relative "dedup"

require_relative "base_responder"
require_relative "t_minus"
require_relative "alchemy"

require_relative "steam"
require_relative "azure"
require_relative "gif"

require_relative "duck"
require_relative "datastore"
