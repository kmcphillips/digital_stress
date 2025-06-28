# frozen_string_literal: true

require "active_support/all"
require "config"
require "discordrb"
require "logger"
require "base64"
require "redis"
require "sqlite3"
require "mysql"
require "sequel"
require "httparty"
require "nokogiri"
require "securerandom"
require "sinatra/base"
require "systemcall"
require "tempfile"
require "fileutils"
require "twilio-ruby"
require "wikipedia"
require "games_dice"
require "ruby/openai"
require "perplexity"
require "aws-sdk-core"
require "aws-sdk-polly"
require "fuzzy_match"
require "timeout"
require "google/apis/calendar_v3"
require "googleauth"

require_relative "vendor/time_difference"

require_relative "global"

Global.environment[:log] ||= ENV["DUCK_LOG_FILE"].presence || Global.root.join("log/bot.log")
Global.environment[:config] ||= ENV["DUCK_CONFIG_FILE"].presence || Global.root.join("config/config.yml.enc")
Global.environment[:config_key] ||= ENV["DUCK_CONFIG_KEY"].presence

require_relative "configuration"
Global.config = Configuration.new(key: Global.environment[:config_key], file: Global.environment[:config]).read

logger_file = if ENV["DUCK_LOG_STDOUT"]
  $stdout
else
  File.open(Global.environment[:log], File::WRONLY | File::APPEND | File::CREAT)
end

logger_file.sync = true
Global.logger = Logger.new(logger_file, level: (Global.config.discord.debug_log ? Logger::DEBUG : Logger::INFO))
Discordrb::LOGGER.streams << logger_file if Global.config.discord.debug_log

if Global.environment[:db] != false
  datastore_url = Global.environment[:db].presence || ENV["DUCK_DB"].presence || Global.config.db.url.presence
  Global.logger.info("Selecting db: Global.environment[:db]: #{Global.environment[:db].inspect} || ENV['DUCK_DB']: #{ENV["DUCK_DB"].inspect} || Global.config.db.url: #{Global.config.db.url.inspect}")
  Global.logger.info("Using db: #{datastore_url}")
  raise "Database URL must be set or explicitly be set to false. Set it in `Global.environment[:db] or DUCK_DB or `db:` in config file." unless datastore_url.present?

  if datastore_url.to_s.start_with?("sqlite://", "mysql://")
    Global.db = Sequel.connect(datastore_url.to_s)
  else
    raise "Do not know how to connect to db: #{datastore_url}"
  end
end

require_relative "persistence/key_value_store"
if Global.environment[:kv] != false
  datastore_url = Global.environment[:kv].presence || ENV["DUCK_KV"].presence || Global.config.kv.url.presence
  Global.logger.info("Selecting kv: Global.environment[:kv]: #{Global.environment[:kv].inspect} || ENV['DUCK_KV']: #{ENV["DUCK_KV"].inspect} || Global.config.kv.url: #{Global.config.kv.url.inspect}")
  Global.logger.info("Using kv: #{datastore_url}")
  raise "Key value store URL must be set or must explicitly be set to false. Set it in `Global.environment[:kv] or DUCK_KV or `kv:` in config file." unless datastore_url.present?

  Global.kv = KeyValueStore.new(datastore_url.to_s)
end

Global.openai_client = OpenAI::Client.new(access_token: Global.config.openai.access_token)

Aws.config.update(
  region: "us-west-2",
  credentials: Aws::Credentials.new(
    Global.config.aws.access_key_id,
    Global.config.aws.secret_access_key
  )
)

require_relative "persistence/recorder"
require_relative "persistence/learner"
require_relative "persistence/flags"
require_relative "persistence/dnd_5e_data"
require_relative "persistence/dnd_5e_parser"

require_relative "util/pinger"
require_relative "util/formatter"
require_relative "util/dedup"
require_relative "util/quacker"
require_relative "util/system_info"

Dir.glob(Global.root.join("lib/models/*.rb")).each { |file| require_relative file }
require_relative "mandate_user_refinements"
User.include(MandateUserRefinements)

require_relative "clients/discord_rest_api"
require_relative "clients/steam"
require_relative "clients/azure"
require_relative "clients/gif"
require_relative "clients/wolfram_alpha"
require_relative "clients/texter"
require_relative "clients/wikipedia_client"
require_relative "clients/openai_client"
require_relative "clients/perplexity_client"
require_relative "clients/aws_client"
require_relative "clients/mandate_models"
require_relative "clients/google_calendar_client"

require_relative "base_command"
require_relative "base_subcommand"
Dir.glob(Global.root.join("lib/commands/concerns/*.rb")).each { |file| require_relative file }
Dir.glob(Global.root.join("lib/commands/*_command.rb")).each { |file| require_relative file }

require_relative "base_responder"
Dir.glob(Global.root.join("lib/responders/concerns/*.rb")).each { |file| require_relative file }
Dir.glob(Global.root.join("lib/responders/*_responder.rb")).each { |file| require_relative file }

require_relative "tasks/task_base"
require_relative "tasks/daily_announcements"

require_relative "web_duck"
require_relative "duck"

Dnd5eData.load
