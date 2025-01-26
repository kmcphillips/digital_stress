require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "filewatcher", "2.0.0.beta2"
  gem "httparty"
end

WATCH_PATH = "TODO"
HTTP_URL = "http://TODO"
HTTP_AUTH = {username: "TODO", password: "TODO"}

puts "Quack... watching #{WATCH_PATH}"

Filewatcher.new(WATCH_PATH).watch do |changes|
  changes.each do |filename, event|
    if event == :created
      username = File.read(filename).strip
      begin
        HTTParty.post("#{HTTP_URL}#{username}", basic_auth: HTTP_AUTH)
      rescue => e
        puts "Quack! Error! #{e.message}"
      end
    end
  end
end
