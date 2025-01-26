# frozen_string_literal: true

class RollCommand < BaseCommand
  def response
    if query.blank?
      "Quack! What do you want to roll? :d20:"
    else
      begin
        str = query
        str = "1#{str}" if /^d[0-9]/.match?(str)
        dice = GamesDice.create(str)
        dice.roll
        "#{Pinger.find_emoji("d20", server: server) || ":game_die:"} **#{dice.result}** \n*(#{dice.explain_result})*"
      rescue Parslet::ParseFailed
        "Quack?? Not sure how to roll '#{query}'!"
      end
    end
  end
end
