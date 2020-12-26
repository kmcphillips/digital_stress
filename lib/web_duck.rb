# frozen_string_literal: true
class WebDuck < Sinatra::Application
  class << self
    attr_accessor :bot
  end

  set :port, Configuration.web_auth.port

  use Rack::Auth::Basic do |username, password|
    username == Configuration.web_auth.username && password == Configuration.web_auth.password
  end

  get '/' do
    'Quack!'
  end

  post '/message/:server/:channel' do
    server = params["server"]
    channel_name = params["channel"]
    message = params["message"]
    channels = self.class.bot.find_channel(channel_name, server)

    Log.warn("No channels found for #{ server }##{ channel_name }") if channels.empty?

    channels.each { |channel| channel.send_message(message) }

    "Quack, ok."
  end

  post '/train_accident/:server/:channel/:username' do
    server = params["server"]
    channel_name = params["channel"]
    username = params["username"]

    channels = self.class.bot.find_channel(channel_name, server)
    Log.warn("No channels found for #{ server }##{ channel_name }") if channels.empty?

    channels.each do |channel|
      db = TrainCommand::Datastore.new(server: server, channel: channel_name)
      user = User.from_input(username)
      db.create_accident(user_id: user&.id)

      begin
        TrainCommand::ImageGenerator.it_has_been_days_file(0) do |file|
          channel.send_file(file)
          nil
        end
      rescue => exception
        Log.error(exception.message)
        Log.error(exception)
        channel.send_message(":bangbang: Quack error with file: #{ exception.message }")
      end
    end

    "Quack, train."
  end
end

# I wonder where this could go that would be better?
raise "web_auth credentials missing" if Configuration.web_auth.username.blank? || Configuration.web_auth.password.blank?
