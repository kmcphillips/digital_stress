# frozen_string_literal: true
class User
  MANDATE_CONFIG = JSON.parse(ENV["MANDATE_PERSONS"])

  attr_reader :username, :id, :discriminator

  def initialize(username:, id:, discriminator:)
    @username = username
    @id = id
    @discriminator = discriminator
  end

  class << self
    def from_discord(user)
      self.new(username: user.username, id: user.id, discriminator: user.discriminator)
    end
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
