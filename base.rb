# frozen_string_literal: true
require "pry"
require "active_support/all"
require "dotenv/load"
require "discordrb"
require "logger"
require "sqlite3"
require "httparty"
require "nokogiri"

require_relative "steam"
require_relative "duck"
require_relative "datastore"
