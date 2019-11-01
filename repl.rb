# frozen_string_literal: true
require "pry"
require "active_support/all"
require "dotenv/load"
require "sqlite3"
require "httparty"
require "nokogiri"

require_relative "steam"
require_relative "datastore"

datastore = Datastore.new
puts datastore.peek



db = datastore.db
binding.pry
