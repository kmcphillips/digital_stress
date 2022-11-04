# frozen_string_literal: true
class AbsurdityChat
  attr_reader :id, :user_id, :server, :message, :username

  def initialize(id:, user_id:, server:, message:, username:)
    @id = id
    @user_id = user_id
    @server = server
    @message = message
    @username = username
  end
end
