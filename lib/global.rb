# frozen_string_literal: true

Global = Class.new do
  attr_accessor :root, :config, :db, :logger, :kv, :bot, :openai_client, :environment

  def domain
    config.web_auth.host
  end
end.new

Global.root = Pathname.new(File.dirname(__FILE__)).join("..").expand_path
Global.environment = {}
