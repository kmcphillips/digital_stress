require "pry"
require "active_support/core_ext"
require "discordrb"

token = ENV["DISCORDRB_TOKEN"].presence

raise "env var DISCORDRB_TOKEN must be set" unless token

# TODO
