# frozen_string_literal: true
require_relative "base"

require "csv"

datastore = Datastore.new
datastore.setup!

raise "pass in the CSV file" unless ARGV[0].present?

def valid_message?(message)
  return false if message.blank?
  return false if message =~ /\Ahttp/
  true
end

CSV.read(ARGV[0], headers: true, col_sep: ";").each do |row|
  if valid_message?(row["Content"])
    datastore.append(row["Author"], row["Content"], Time.parse(row["Date"]))
    print "."
  end
end

puts " done"
