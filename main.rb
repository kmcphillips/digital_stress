# frozen_string_literal: true
require "pry"
require "active_support/all"
require "dotenv/load"
require "discordrb"
require "logger"

require_relative "quack"

token = ENV["DISCORDRB_TOKEN"].presence

logger_file = File.open("bot.log", File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
logger = Logger.new(logger_file)
logger.level = Logger::INFO

raise "env var DISCORDRB_TOKEN must be set" unless token

Quack.new(token: token, logger: logger).quack
