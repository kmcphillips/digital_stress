# frozen_string_literal: true
class RollCommand < BaseCommand
  def response
    if query.blank?
      "Quack! What do you want to roll? :d20:"
    else
      begin
        str = query
        str = "1#{ str }" if str =~ /^d[0-9]/
        dice = GamesDice.create(str)
        dice.roll
        "#{ d20_emoji } **#{ dice.result }** \n*(#{ dice.explain_result })*"
      rescue Parslet::ParseFailed => e
        "Quack?? Not sure how to roll '#{ query }'!"
      end
    end
  end

  private

  def d20_emoji
    event.server.emoji.values.find { |e| e.name == "d20" } || ":d20:"
  end
end
