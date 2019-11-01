# frozen_string_literal: true
require_relative "base"

datastore = Datastore.new
puts datastore.peek



db = datastore.db
binding.pry
