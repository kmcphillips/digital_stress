# frozen_string_literal: true
class BaseResponder
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def respond
    raise NotImplementedError
  end
end
