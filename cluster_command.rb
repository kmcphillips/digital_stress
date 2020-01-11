# frozen_string_literal: true
class ClusterCommand < BaseCommand
  def response
    deadline = Date.new(2020, 3, 24)
    days = (deadline - Date.today).to_i

    if days == 1
      ":bangbang: #{ Duck::QUACKS.sample }, Cluster festival is tomorrow!"
    elsif days <= 0
      "#{ Duck::QUACKS.sample }, hope Cluster went ok."
    else
      weeks = (days / 7).to_i
      ":information_source: #{ Duck::QUACKS.sample }, Cluster festival is in #{ days } days (#{ weeks } weeks)."
    end
  end
end
