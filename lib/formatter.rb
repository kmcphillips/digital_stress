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
    (input || "").gsub("\n", " ")
  end

  def number(value)
    value = value.to_s.split('.')
    value[0].reverse!.gsub!(/(\d{3})(?=\d)/, '\\1,').reverse! if value[0].length > 4
    value.join('.')
  end
end
