# frozen_string_literal: true

Global = Class.new do
  attr_accessor :root, :config, :db, :logger, :kv, :bot, :openai_client, :environment

  def domain
    config.web_auth.host
  end

  def env
    @env ||= Env.new(config.env.presence || "")
  end

  class Env < String
    def initialize(*)
      super
      self.downcase!
      self.strip!
      self.freeze
      raise "env: is required in config file" if self.empty?
      raise "invalid env: #{self}" unless %w[production development test].include?(self)
    end

    def production?
      self == "production"
    end

    def development?
      self == "development"
    end

    def test?
      self == "test"
    end
  end
end.new

Global.root = Pathname.new(File.dirname(__FILE__)).join("..").expand_path
Global.environment = {}
