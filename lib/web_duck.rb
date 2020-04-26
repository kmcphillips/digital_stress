# frozen_string_literal: true
class WebDuck < Sinatra::Application
  class << self
    attr_accessor :bot
  end

  def channels
    ENV["WEB_NOTIFY_CHANNELS"]
      .split(",")
      .reject(&:blank?)
      .map(&:to_i)
      .map { |id| self.class.bot.channel(id) }
  end

  def notify_channels(messages)
    channels.each do |channel|
      Array(messages).each do |message|
        channel.send_message(message)
      end
    end
  end

  set :port, 4444

  use Rack::Auth::Basic do |username, password|
    username == ENV["WEB_AUTH_USERNAME"] && password == ENV["WEB_AUTH_PASSWORD"]
  end

  get '/' do
    'Quack!'
  end

  post '/quigital/new_caller' do
    phone_number = params["phone_number"]
    location = params["location"]
    url = params["url"]

    message = ":telephone: New Quigital caller `#{ phone_number }` #{ location } #{ url }"

    notify_channels(message)

    "Quack, ok."
  end

  post '/quigital/ending' do
    phone_number = params["phone_number"]
    location = params["location"]
    url = params["url"]

    message = ":tada: Quigital ending `#{ phone_number }` #{ location } #{ url }"

    notify_channels(message)

    "Quack, ok."
  end
end
