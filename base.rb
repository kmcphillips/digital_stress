# frozen_string_literal: true
require "pry"
require "active_support/all"
require "config"
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
require "systemcall"
require "tempfile"
require "twilio-ruby"

class Duck
  class << self
    def root
      @root ||= Pathname.new(File.dirname(__FILE__))
    end
  end
end

Config.setup { |config| config.const_name = 'Configuration' }
Config.load_and_set_settings(Duck.root.join("config/config.yml"))

logger_file = File.open(Duck.root.join("bot.log"), File::WRONLY | File::APPEND | File::CREAT)
logger_file.sync = true
Log = Logger.new(logger_file)
Log.level = Logger::INFO

db_file = Duck.root.join("chat.sqlite3").to_s
DB = Sequel.sqlite(db_file)

require_relative "lib/persistence/key_value_store"
KV = KeyValueStore.new(DB.opts[:database]) # Configuration.redis.url

require_relative "lib/persistence/recorder"
require_relative "lib/persistence/learner"

require_relative "lib/util/pinger"
require_relative "lib/util/formatter"
require_relative "lib/util/dedup"

require_relative "lib/models/user"
require_relative "lib/mandate_user_refinements"

require_relative "lib/clients/steam"
require_relative "lib/clients/azure"
require_relative "lib/clients/gif"
require_relative "lib/clients/wolfram_alpha"
require_relative "lib/clients/texter"

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
require_relative "lib/commands/toggle_the_record_command"
require_relative "lib/commands/off_the_record_command"
require_relative "lib/commands/on_the_record_command"
require_relative "lib/commands/wolfram_alpha_command"
require_relative "lib/commands/chat_command"
require_relative "lib/commands/train_command"
require_relative "lib/commands/text_command"
require_relative "lib/commands/alchemy_command"

require_relative "lib/responders/base_responder"
require_relative "lib/responders/simple_responder"
require_relative "lib/responders/t_minus_responder"
require_relative "lib/responders/alchemy_responder"
require_relative "lib/responders/google_image_search_responder"
require_relative "lib/responders/temperature_responder"

require_relative "lib/web_duck"
require_relative "lib/duck"
