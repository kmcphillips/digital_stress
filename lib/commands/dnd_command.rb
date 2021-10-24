# frozen_string_literal: true
class DndCommand < BaseCommand
  def response
    AnnouncementCommand.new(event: event, bot: bot, params: ["list"]).send(:list)
  end
end
