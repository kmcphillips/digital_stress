# frozen_string_literal: true
class RollCommand < BaseCommand
  def response
    dice = GamesDice.create(query)
    dice.roll
    ":d20: **#{ dice.result }** \n*(#{ dice.explain_result })*"
  end
end
