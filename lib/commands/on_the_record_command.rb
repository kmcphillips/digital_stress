# frozen_string_literal: true
class OnTheRecordCommand < ToggleTheRecordCommand
  def record?
    true
  end
end
