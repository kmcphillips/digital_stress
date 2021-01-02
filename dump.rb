# frozen_string_literal: true
require_relative "base"

Recorder.dump.each do |user_id, record|
  filename = Duck.root.join("data/output/#{ record[:username] }_#{ Time.now.strftime("%F") }.txt")

  File.open(filename, "w") do |f|
    f.write(record[:messages].join("\n"))
  end

  puts filename
end
