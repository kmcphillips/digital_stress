# frozen_string_literal: true
class TaskBase
  def initialize
  end

  def run
    raise NotImplementedError
  end
end
