# frozen_string_literal: true

module Formatter
  extend self

  def parse_timestamp(input)
    case input
    when NilClass
      Time.now.to_i
    when Time
      input.to_i
    when Integer
      input
    else
      raise "Unknown time #{input}"
    end
  end

  def compact_multiline(input)
    (input || "").tr("\n", " ")
  end

  def number(value)
    value = value.to_s.split(".")
    value[0].reverse!.gsub!(/(\d{3})(?=\d)/, '\\1,').reverse! if value[0].length > 4
    value.join(".")
  end

  PHONE_NUMBER_REGEX = /\A\+1[0-9]{10}\Z/

  def phone_number(string)
    string = string.presence

    if string
      string = string.gsub(/[^0-9]/, "")
      string = "1#{string}" unless string.starts_with?("1")
      string = "+#{string}"
      string = nil unless string.match?(PHONE_NUMBER_REGEX)
    end

    string
  end

  def parse_minutes_from(str)
    if str.blank?
      nil
    elsif (matches = str.match(/(\d+\s?m)/))
      matches[1].to_i
    elsif (matches = str.match(/(\d+\s?h)/))
      matches[1].to_i * 60
    elsif (matches = str.match(/(\d+\s?d)/))
      matches[i].to_i * 60 * 24
    end
  end

  def too_long?(message, max_length = Duck::MAX_MESSAGE_LENGTH)
    message.is_a?(String) && message.length >= max_length
  end

  def truncate_too_long(message, max_length = Duck::MAX_MESSAGE_LENGTH)
    if too_long?(message, max_length)
      "#{message.slice(0..(max_length - 5))} ..."
    else
      message
    end
  end
end
