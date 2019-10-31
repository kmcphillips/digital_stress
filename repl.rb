# frozen_string_literal: true
require "pry"
require "active_support/all"
require "dotenv/load"
require "sqlite3"

require_relative "datastore"

db = Datastore.new
binding.pry
