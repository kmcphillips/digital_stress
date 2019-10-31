# frozen_string_literal: true
require "pry"
require "active_support/all"
require "dotenv/load"
require "sqlite3"
require "csv"

require_relative "datastore"

datastore = Datastore.new

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
