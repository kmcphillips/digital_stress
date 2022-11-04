# frozen_string_literal: true
module AbsurdityChatStore
  extend self

  def consume(user_id:, server:)
    record = table
      .where(server: server, user_id: user_id, consumed_timestamp: nil)
      .order(Sequel.lit('RANDOM()'))
      .first

    return nil unless record

    table.where(id: record[:id]).update(consumed_timestamp: Time.now.to_i)

    AbsurdityChat.new(**record.except(:consumed_timestamp))
  end

  def any?(user_id:, server:)
    table.where(server: server, user_id: user_id).count > 0
  end

  def create(user_id:, username:, server:, message:)
    args = {
      user_id: user_id,
      username: username,
      server: server,
      message: message,
    }

    table.insert(args)
  end

  def tally(server:)
    table.where(server: server, consumed_timestamp: nil).group_and_count(:user_id).all
  end

  private

  def table
    Global.db[:absurdity_chats]
  end
end
