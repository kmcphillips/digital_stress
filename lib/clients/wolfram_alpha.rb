# frozen_string_literal: true

module WolframAlpha
  extend self

  MAX_VALUE_LENGTH = 500

  def query(search, location: nil)
    url = "http://api.wolframalpha.com/v2/query?input=#{CGI.escape(search.strip)}&appid=#{appid}"
    url = "#{url}&location=#{CGI.escape(location.strip)}" if location.present?
    url = "#{url}&format=plaintext" # ,image

    response = HTTParty.get(url)

    if !response.success?
      Global.logger.error("WolframAlpha#query returned HTTP #{response.code}")
      Global.logger.error(response.body)

      ":bangbang: Quack failure HTTP#{response.code}"
    else
      Global.logger.info("WolframAlpha#query success")
      Global.logger.info(response.body)

      Response.new(response.to_h).to_a
    end
  end

  private

  def appid
    Global.config.wolfram_alpha.appid
  end

  class Response
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def to_a
      if error?
        parse_error
      elsif didyoumean?
        parse_didyoumean
      elsif tips?
        parse_tips
      elsif primary_pod? # TODO This seems to most always be true
        parse_primary_pod
      elsif pod?
        parse_pod
      elsif futuretopic?
        parse_futuretopic
      else
        [":interrobang: Don't know what to make of this response."]
      end
    end

    def to_s
      to_a.join("\n")
    end

    private

    def error?
      data["queryresult"]["error"] != "false"
    end

    def parse_error
      ":bangbang: #{data["queryresult"]["error"]}"
    end

    def didyoumean?
      !!data["queryresult"]["didyoumeans"]
    end

    def parse_didyoumean
      array = [":thinking: Did you mean?"]
      dyms = data["queryresult"]["didyoumeans"]["didyoumean"]
      dyms = [dyms] unless dyms.is_a?(Array)
      dyms.each do |dym|
        array << "    #{dym["__content__"]} (#{dym["score"].to_f.round(1) * 100}%)"
      end
      array
    end

    def tips?
      !!data["queryresult"]["tips"]
    end

    def parse_tips
      tips = data["queryresult"]["tips"]["tip"]
      tips = [tips] unless tips.is_a?(Array)
      tips.map do |tip|
        ":information_source: #{tip["text"]}"
      end
    end

    def primary_pod?
      data["queryresult"]["pod"] && data["queryresult"]["pod"].any? { |p| p["primary"] }
    end

    def parse_primary_pod
      lines = []
      images = []

      if pod = data["queryresult"]["pod"].find { |p| p["id"] == "Input" }
        lines << "#{pod["subpod"]["plaintext"]}"
      end

      if pod = data["queryresult"]["pod"].find { |p| p["primary"] }
        lines << if pod["subpod"].is_a?(Array)
          "#{pod["subpod"].map { |s| s["plaintext"] }.join("\n")}"
        else
          "**#{pod["subpod"]["plaintext"]}**"
        end
      end

      data["queryresult"]["pod"].each do |pod|
        if pod["id"] != "Input"
          subpods = pod["subpod"]
          subpods = [subpods] if subpods.is_a?(Hash)
          subpods.each do |subpod|
            images << subpod["imagesource"] if subpod["imagesource"]
          end
        end
      end

      (lines + images).compact
    end

    def pod?
      !!data["queryresult"]["pod"]
    end

    def parse_pod
      prefix = []
      lines = []
      images = []

      if pod = data["queryresult"]["pod"].find { |p| p["id"] == "Input" }
        prefix << "#{pod["subpod"]["plaintext"]}"
      end

      data["queryresult"]["pod"].each do |pod|
        if pod["id"] != "Input"
          subpods = pod["subpod"]
          subpods = [subpods] if subpods.is_a?(Hash)
          values = subpods.map do |subpod|
            if subpod["imagesource"]
              images << subpod["imagesource"]
              nil
            elsif subpod["plaintext"].present?
              subpod["plaintext"]
            end
          end.compact
          if !values.blank?
            str = values.join("\n")
            str = "#{str.slice(0..MAX_VALUE_LENGTH)} [snip]" if str.length >= MAX_VALUE_LENGTH
            lines << "**#{pod["title"]}** : #{str}"
          end
        end
      end

      (prefix + images + lines).compact
    end

    def futuretopic?
      !!data["queryresult"]["futuretopic"]
    end

    def parse_futuretopic
      lines = []
      lines << ":woman_scientist: **#{data["queryresult"]["futuretopic"]["topic"]}** : #{data["queryresult"]["futuretopic"]["msg"]}"
      lines
    end
  end
end
