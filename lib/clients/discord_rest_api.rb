# frozen_string_literal: true
module DiscordRestApi
  extend self

  def create_guild_scheduled_event(name:, description:, location:, start_time:, end_time: nil, image: nil, server:)
    params = {
      "name" => name,
      "description" => description,
      "privacy_level" => 2,
      "entity_type" => 3,
      "entity_metadata" => { "location" => location },
      "scheduled_start_time" => start_time,
    }

    params["scheduled_end_time"] = end_time if end_time
    params["image"] = "data:image/png;base64,#{ Base64.strict_encode64(File.read(image)) }" if image

    post("/guilds/#{ server_id(server) }/scheduled-events", params: params)
  end

  private

  def post(path, params:)
    begin
      Global.logger.info("[DiscordRestApi] POST #{ path } #{ params.inspect }}")
      response = Discordrb::API.raw_request(
        :post,
        [
          "#{ Discordrb::API.api_base }#{ path }",
          params.to_json,
          headers.merge({ "Content-Type" => "application/json" })
        ]
      )

      if response.code != 200
        Global.logger.error("[DiscordRestApi] POST #{ path } response error #{ response.inspect }")
        raise "DiscordRestApi POST #{ path } response error #{ response.inspect }"
      else
        parsed_response = JSON.parse(response.body)
        Global.logger.info("[DiscordRestApi] POST #{ path } response success #{ parsed_response.inspect }")
        parsed_response
      end
    rescue RestClient::Exception => e
      Global.logger.error("[DiscordRestApi] POST #{ path } response error #{ e.inspect }")
      raise
    end
  end

  def headers
    {
      "Authorization" => Global.bot.token,
    }
  end

  def server_id(server)
    id = Global.bot.servers.values.find { |s| s.name == server.to_s }&.id
    raise "Server not found: #{ server }" unless id
    id
  end
end
