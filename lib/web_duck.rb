# frozen_string_literal: true
class WebDuck < Sinatra::Application
  class << self
    attr_accessor :bot
  end

  set :port, ENV["WEB_PORT"]

  use Rack::Auth::Basic do |username, password|
    username == ENV["WEB_AUTH_USERNAME"] && password == ENV["WEB_AUTH_PASSWORD"]
  end

  get '/' do
    'Quack!'
  end

  post '/message/:server/:channel' do
    server = params["server"]
    channel = params["channel"]
    message = params["message"]
    channels = self.class.bot.find_channels(channel, server)

    Log.warn("No channels found for #{ server }##{ channel }") if channels.empty?

    channels.each { |channel| channel.send_message(message) }

    "Quack, ok."
  end
end
