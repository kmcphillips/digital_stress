# frozen_string_literal: true
class PingCommand < BaseCommand
  def response
    ":white_check_mark: #{ Duck.quack }"
  end
end
