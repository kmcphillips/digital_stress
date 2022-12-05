# frozen_string_literal: true
require "active_support/all"
require "config"
require "discordrb"
require "logger"
require "redis"
require "sqlite3"
require "mysql"
require "sequel"
require "httparty"
require "nokogiri"
require "google/protobuf"
require "grpc"
require "time_difference"
require "securerandom"
require "sinatra/base"
require "systemcall"
require "tempfile"
require "fileutils"
require "open3"
require "twilio-ruby"
require "wikipedia"
require "games_dice"
require "ruby/openai"
require "aws-sdk-core"
require "aws-sdk-polly"
require "fuzzy_match"
require "timeout"

require_relative "lib/global"

Global.environment[:log] ||= ENV["DUCK_LOG_FILE"].presence || Global.root.join("bot.log")
Global.environment[:config] ||= ENV["DUCK_CONFIG_FILE"].presence || Global.root.join("config/config.yml.enc")
Global.environment[:config_key] ||= ENV["DUCK_CONFIG_KEY"].presence

require_relative "lib/configuration"
Global.config = Configuration.new(key: Global.environment[:config_key], file: Global.environment[:config]).read

logger_file = if ENV["DUCK_LOG_STDOUT"]
  STDOUT
else
  File.open(Global.environment[:log], File::WRONLY | File::APPEND | File::CREAT)
end

logger_file.sync = true
Global.logger = Logger.new(logger_file, level: (Global.config.discord.debug_log ? Logger::DEBUG : Logger::INFO))
Discordrb::LOGGER.streams << logger_file if Global.config.discord.debug_log

if Global.environment[:db] != false
  datastore_url = Global.environment[:db].presence || ENV["DUCK_DB"].presence || Global.config.db.url.presence
  Global.logger.info("Selecting db: Global.environment[:db]: #{ Global.environment[:db].inspect } || ENV['DUCK_DB']: #{ ENV['DUCK_DB'].inspect } || Global.config.db.url: #{ Global.config.db.url.inspect }")
  Global.logger.info("Using db: #{ datastore_url }")
  raise "Database URL must be set or explicitly be set to false. Set it in `Global.environment[:db] or DUCK_DB or `db:` in config file." unless datastore_url.present?

  if datastore_url.to_s.start_with?("sqlite://") || datastore_url.to_s.start_with?("mysql://")
    Global.db = Sequel.connect(datastore_url.to_s)
  else
    raise "Do not know how to connect to db: #{ datastore_url }"
  end
end

require_relative "lib/persistence/key_value_store"
if Global.environment[:kv] != false
  datastore_url = Global.environment[:kv].presence || ENV["DUCK_KV"].presence || Global.config.kv.url.presence
  Global.logger.info("Selecting kv: Global.environment[:kv]: #{ Global.environment[:kv].inspect } || ENV['DUCK_KV']: #{ ENV['DUCK_KV'].inspect } || Global.config.kv.url: #{ Global.config.kv.url.inspect }")
  Global.logger.info("Using kv: #{ datastore_url }")
  raise "Key value store URL must be set or must explicitly be set to false. Set it in `Global.environment[:kv] or DUCK_KV or `kv:` in config file." unless datastore_url.present?

  Global.kv = KeyValueStore.new(datastore_url.to_s)
end

Global.openai_client = OpenAI::Client.new(access_token: Global.config.openai.access_token)

Aws.config.update(
  region: 'us-west-2',
  credentials: Aws::Credentials.new(
    Global.config.aws.access_key_id,
    Global.config.aws.secret_access_key
  )
)

require_relative "lib/persistence/recorder"
require_relative "lib/persistence/learner"
require_relative "lib/persistence/flags"
require_relative "lib/persistence/dnd_5e_data"
require_relative "lib/persistence/dnd_5e_parser"
require_relative "lib/persistence/absurdity_chat_store"

require_relative "lib/util/pinger"
require_relative "lib/util/formatter"
require_relative "lib/util/dedup"
require_relative "lib/util/quacker"
require_relative "lib/util/system_info"

require_relative "lib/models/user"
require_relative "lib/mandate_user_refinements"
require_relative "lib/models/announcement"
require_relative "lib/models/absurdity_chat"

require_relative "lib/protobuf/dreamstudio/generation_pb"
require_relative "lib/protobuf/dreamstudio/generation_services_pb"

require_relative "lib/clients/steam"
require_relative "lib/clients/azure"
require_relative "lib/clients/gif"
require_relative "lib/clients/wolfram_alpha"
require_relative "lib/clients/texter"
require_relative "lib/clients/wikipedia_client"
require_relative "lib/clients/openai_client"
require_relative "lib/clients/dreamstudio"
require_relative "lib/clients/aws_client"

require_relative "lib/base_command"
require_relative "lib/base_subcommand"

require_relative "lib/commands/concerns/after_recorder_againable"
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
require_relative "lib/commands/wikipedia_command"
require_relative "lib/commands/again_command"
require_relative "lib/commands/abort_command"
require_relative "lib/commands/announcement_command"
require_relative "lib/commands/roll_command"
require_relative "lib/commands/openai_command"
require_relative "lib/commands/imagine_command"
require_relative "lib/commands/reimagine_command"
require_relative "lib/commands/haiku_command"
require_relative "lib/commands/what_command"
require_relative "lib/commands/dnd_command"
require_relative "lib/commands/notifications_command"
require_relative "lib/commands/quigital_command"

require_relative "lib/responders/concerns/responder_matcher"
require_relative "lib/responders/base_responder"
require_relative "lib/responders/simple_responder"
require_relative "lib/responders/t_minus_responder"
require_relative "lib/responders/alchemy_responder"
require_relative "lib/responders/google_image_search_responder"
require_relative "lib/responders/temperature_responder"
require_relative "lib/responders/topic_responder"
require_relative "lib/responders/ai_responder"

require_relative "lib/tasks/task_base"
require_relative "lib/tasks/daily_announcements"

require_relative "lib/web_duck"
require_relative "lib/duck"

Dnd5eData.load
