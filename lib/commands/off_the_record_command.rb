# frozen_string_literal: true
class OffTheRecordCommand < ToggleTheRecordCommand
  def record?
    false
  end
end
