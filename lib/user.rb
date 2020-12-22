# frozen_string_literal: true
class User
  MANDATE_CONFIG = JSON.parse(ENV["MANDATE_PERSONS"])
  MANDATE_CONFIG_BY_ID = MANDATE_CONFIG.to_h { |name,cfg| [cfg["id"], cfg] }

  attr_reader :username, :id, :discriminator, :location, :phone_number

  def initialize(username:, id:, discriminator:)
    @username = username
    @id = id
    @discriminator = discriminator
    @mandate_config = MANDATE_CONFIG_BY_ID[id]
    @location = nil
    @phone_number = nil

    @location = @mandate_config["location"] if @mandate_config
    @phone_number = @mandate_config["phone_number"] if @mandate_config
  end

  class << self
    def from_discord(user)
      return nil unless user
      self.new(username: user.username, id: user.id, discriminator: user.discriminator)
    end

    def from_id(user_id)
      return nil unless user_id.present?
      cfg = MANDATE_CONFIG_BY_ID[user_id.to_i]
      return nil unless cfg
      self.new(cfg.slice("username", "id", "discriminator").symbolize_keys)
    end

    def from_fuzzy_match(string)
      return nil unless string.present?
      fuzzy_match = string.to_s.strip.downcase
      found_name, cfg = MANDATE_CONFIG.find do |name, value|
        name == fuzzy_match || value["username"] == fuzzy_match
      end
      return nil unless cfg
      self.new(cfg.slice("username", "id", "discriminator").symbolize_keys)
    end

    def from_input(string)
      return nil unless string.present?
      User.from_fuzzy_match(string) || User.from_id(string) || User.from_id(Pinger.extract_user_id(string))
    end

    def dave
      self.new(**MANDATE_CONFIG["dave"].slice("username", "id", "discriminator").symbolize_keys)
    end

    def eliot
      self.new(**MANDATE_CONFIG["eliot"].slice("username", "id", "discriminator").symbolize_keys)
    end

    def kevin
      self.new(**MANDATE_CONFIG["kevin"].slice("username", "id", "discriminator").symbolize_keys)
    end

    def patrick
      self.new(**MANDATE_CONFIG["patrick"].slice("username", "id", "discriminator").symbolize_keys)
    end
  end

  def <=>(other)
    if other.is_a?(::User)
      other.id <=> id
    else
      super
    end
  end

  def ==(other)
    if other.is_a?(::User)
      other.id == id
    else
      super
    end
  end

  def mention
    "<@#{ id }>"
  end

  def dave?
    MANDATE_CONFIG["dave"]["id"] == id
  end

  def eliot?
    MANDATE_CONFIG["eliot"]["id"] == id
  end

  def kevin?
    MANDATE_CONFIG["kevin"]["id"] == id
  end

  def patrick?
    MANDATE_CONFIG["patrick"]["id"] == id
  end
end
