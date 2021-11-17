# frozen_string_literal: true
class User
  USERS = Global.config.servers.each_with_object({}) do |(server_name, cfg), obj|
    obj[server_name.to_s] = cfg.users.map(&:to_h).map{ |u| [u[:id], u] }.to_h
  end

  attr_reader :username, :id, :server, :discriminator, :location, :phone_number

  def initialize(username:, id:, server:, discriminator:)
    @username = username
    @id = id
    @server = server
    @discriminator = discriminator
    @location = nil
    @phone_number = nil

    # Load extras from the config.yml Global.config object
    @config = USERS.dig(server, id)
    @location = @config[:location] if @config
    @phone_number = @config[:phone_number] if @config
  end

  class << self
    def from_discord(user, server:)
      return nil unless user
      self.new(username: user.username, id: user.id, discriminator: user.discriminator, server: server)
    end

    def from_id(user_id, server:)
      return nil unless user_id.present?
      return nil unless server.present? && USERS.keys.include?(server.to_s)
      from_config(config: USERS[server.to_s][user_id.to_i], server: server)
    end

    def from_fuzzy_match(string, server:)
      return nil unless string.present?
      return nil unless server.present? && USERS.keys.include?(server.to_s)
      fuzzy_match = string.to_s.strip.downcase
      cfg = USERS[server.to_s].values.find do |value|
        value[:name].downcase == fuzzy_match || value[:username].downcase == fuzzy_match
      end
      from_config(config: cfg, server: server)
    end

    def from_input(string, server:)
      return nil unless string.present?
      User.from_fuzzy_match(string, server: server) || User.from_id(string, server: server) || User.from_id(Pinger.extract_user_id(string), server: server)
    end

    def from_config(config:, server:)
      return nil unless config
      self.new(**config.slice(:username, :id, :discriminator).merge(server: server))
    end

    def all(server:)
      (USERS[server.to_s] || {}).values.map { |cfg| from_config(config: cfg, server: server) }
    end
  end

  def <=>(other)
    if other.is_a?(::User)
      res = other.server <=> server

      if res == 0
        other.id <=> id
      else
        res
      end
    else
      super
    end
  end

  def ==(other)
    if other.is_a?(::User)
      other.id == id && other.server == server
    else
      super
    end
  end

  def mention
    "<@#{ id }>"
  end
end
