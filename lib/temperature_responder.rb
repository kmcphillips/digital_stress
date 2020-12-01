# frozen_string_literal: true
class TemperatureResponder < BaseResponder
  REGEX_FARENHEIT = /(?:\s|^)((?:-\s?)?\d+(?:\.\d+)?)\s?(?:degrees?\s)?f(?:\b|(?:arenheit))/i
  REGEX_CELCIUS = /(?:\s|^)((?:-\s?)?\d+(?:\.\d+)?)\s?(?:degrees?\s)?c(?:\b|(?:elcius))/i
  REGEX_KELVIN = /(?:\s|^)((?:-\s?)?\d+(?:\.\d+)?)\s?(?:degrees?\s)?k(?:\b|(?:elvin))/i
  REGEX_DEGREES_WITHOUT_UNIT = /(?:\s|^)((?:-\s?)?\d+(?:\.\d+)?\s?degrees?)(?:$|(?:\s[^fc]))/i

  def respond
    if match = text.match(REGEX_FARENHEIT)
      f = match[0]
      event.respond(":thermometer: #{ round_pretty(f_to_c(f)) } C")
    elsif match = text.match(REGEX_CELCIUS)
      c = match[0]
      event.respond(":thermometer: #{ round_pretty(c_to_f(c)) } F")
    elsif match = text.match(REGEX_KELVIN)
      k = match[0]
      if k.to_f < 0.0
        event.respond(":thermometer: Impossible")
      else
        event.respond(":thermometer: #{ round_pretty(k_to_c(k)) } C")
      end
    elsif match = text.match(REGEX_DEGREES_WITHOUT_UNIT)
      d = match[0]
      event.respond(":thermometer: #{ d } in Celcius or American?")
    end
  end

  private

  def f_to_c(input)
    ( input.to_f - 32 ) * 5 / 9
  end

  def c_to_f(input)
    ( input.to_f * 9 / 5 ) + 32
  end

  def k_to_c(input)
    input.to_f - 273.15
  end

  def round_pretty(input)
    "%g" % (input.to_f).round(1)
  end
end
