# frozen_string_literal: true

class WebDuck < Sinatra::Application
  set :port, Global.config.web_auth.port

  get "/" do
    Quacker.quack
  end

  get "/ping" do
    summary = SystemInfo.short_summary
    if !Global.bot.connected?
      status 503
      summary += " Discord connection lost"
    end
    "PONG (#{summary})"
  end

  get "/heartbeat" do
    if !Global.bot.connected?
      status 503
      "UNHEALTHY (not connected to Discord)"
    elsif !Global.db.test_connection
      status 503
      "UNHEALTHY (database connection failed)"
    # TODO: add check for Redis connection
    else
      "HEALTHY"
    end
  end

  get "/calendar/dnd.ics" do
    announcements = Announcement
      .all(server: "mandatemandate")
      .reject(&:secret)
      .reject(&:long_expired?)
      .reject(&:cancelled?)
      .select { |x| x.channel == "dnd" }
      .sort_by(&:id)

    calendar = Calendar.new(announcements,
      name: "D&D mandate",
      hostname: Global.config.web_auth.host,
      url: "https://#{Global.config.web_auth.host}/calendar/dnd.ics",
      organizer_email: User.kevin.email)

    content_type "text/calendar"
    calendar.to_ics
  end

  post "/message/:server/:channel" do
    web_auth!

    server = params["server"]
    channel_name = params["channel"]
    message = params["message"]
    channels = Global.bot.find_channel(channel_name, server)

    Global.logger.warn("No channels found for #{server}##{channel_name}") if channels.empty?

    if !Flags.active?("silence_notifications", server: server)
      channels.each { |channel| channel.send_message(message) }
      "Quack, ok."
    else
      "Quack, silenced."
    end
  end

  post "/train_accident/:server/:channel/:username" do
    web_auth!

    server = params["server"]
    channel_name = params["channel"]
    username = params["username"]

    channels = Global.bot.find_channel(channel_name, server)
    Global.logger.warn("No channels found for #{server}##{channel_name}") if channels.empty?

    channels.each do |channel|
      db = TrainCommand::Datastore.new(server: server, channel: channel_name)
      user = User.from_input(username, server: server)
      db.create_accident(user_id: user&.id)

      begin
        channel.send_message(":steam_locomotive: :boom: #{user.mention}") if user
        TrainCommand::ImageGenerator.it_has_been_days_file(0) { |file| channel.send_file(file) }
      rescue => exception
        Global.logger.error(exception.message)
        Global.logger.error(exception)
        channel.send_message(":bangbang: Quack there was a train accident in the duck bot too: #{exception.message}")
      end
    end

    "Quack, train."
  end

  post "/twilio/:server/:channel/message" do
    server = params["server"]
    channel_name = params["channel"]

    Global.logger.error("Received Twilio server=#{server} channel=#{channel_name}: #{params}")

    channels = Global.bot.find_channel(channel_name, server)
    Global.logger.warn("No channels found for #{server}##{channel_name}") if channels.empty?

    if Flags.active?("silence_notifications", server: server)
      "Quack, silenced."
    else
      if params["SmsStatus"] == "received"
        user = User.from_phone(params["From"], server: server)

        channels.each do |channel|
          message = if user
            "> 📲 **#{user.username}**: #{params["Body"]}"
          else
            "> 📲 **#{params["From"].presence || "(unknown number)"}**: #{params["Body"]}"
          end

          channel.send_message(message)
        end
      end

      "Quack, OK."
    end
  end

  helpers do
    def web_auth!
      return if authorized?
      headers["WWW-Authenticate"] = "Basic realm=\"Restricted Area\""
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == web_auth_credentials
    end

    def web_auth_credentials
      [Global.config.web_auth.username, Global.config.web_auth.password]
    end
  end
end

# I wonder where this could go that would be better?
raise "web_auth credentials missing" if Global.config.web_auth.username.blank? || Global.config.web_auth.password.blank?
