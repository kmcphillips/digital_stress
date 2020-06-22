# frozen_string_literal: true
class BaseResponder
  attr_reader :event, :bot

  def initialize(event, bot:)
    @event = event
    @bot = bot
  end

  def respond
    raise NotImplementedError
  end

  def text
    event.message.content
  end
end
