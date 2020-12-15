# frozen_string_literal: true
class TrainCommand < BaseCommand
  def channels
    [
      "mandatemandate#general",
      "duck-bot-test#testing",
    ]
  end

  def response
    db = TrainCommand::Datastore.new(server: server, channel: channel)

    if params[0].blank?
      respond_with_accident(db.days_since_last_accident)
    elsif params[0]&.downcase == "accident"
      user = User.from_input(params[1])
      event.message.react("💥")
      db.create_accident(user_id: user&.id)
      respond_with_accident(0)
    else
      ":steam_locomotive: To record a new accident `duck train accident` or just `duck train` to check accident sign."
    end
  end

  private

  def respond_with_accident(num)
    event.channel.start_typing

    begin
      TrainCommand::ImageGenerator.it_has_been_days_file(num) do |file|
        event.send_file(file)
        nil
      end
    rescue => exception
      Log.error(exception.message)
      Log.error(exception)
      ":bangbang: Quack error with file: #{ exception.message }"
    end
  end

  class Datastore
    attr_reader :server, :channel

    def initialize(server:, channel:)
      @server = server
      @channel = channel
    end

    def last_accident
      table.order(Sequel.desc(:timestamp)).where(server: server).limit(1).first
    end

    def days_since_last_accident
      l = last_accident
      return 0 unless l
      ( ( ( Time.now.to_i - l[:timestamp] ) / 60 / 60 / 24 ).to_f ).to_i
    end

    def create_accident(user_id: nil)
      args = {
        timestamp: Time.now.to_i,
        user_id: user_id,
        server: server,
        channel:channel,
      }

      Log.info("create_accident(#{ args }")
      table.insert(args)
    end

    private

    def table
      DB[:train_accidents]
    end
  end

  module ImageGenerator
    extend self

    SIGN_TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "data", "train_accident_template.png"))

    def it_has_been_days_file(days)
      raise "Cannot find file '#{  }'" unless File.exists?(SIGN_TEMPLATE_PATH)

      Tempfile.create(["train_duck", ".png"]) do |temp|
        response = SystemCall.call("convert \"#{ SIGN_TEMPLATE_PATH }\" -font helvetica -pointsize 100 -draw \"text 100,100 '#{ days }'\" \"#{ temp.path }\"")
        if response.success?
          yield(temp)
        else
          raise "'convert' did not exit success: #{ response.result }"
        end
      end
      nil
    end
  end
end
