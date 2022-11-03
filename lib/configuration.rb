# frozen_string_literal: true

# You can't tell rubyconfig to not export a `const_name` so just call it something dumb and never reference it
CONFIG_CONST_NAME = 'IgnoreMeGlobalConfiguration'

Config.setup do |config|
  config.const_name = CONFIG_CONST_NAME
  config.evaluate_erb_in_yaml = false
end

class Configuration
  attr_reader :key, :file

  def initialize(key:, file:)
    @key = key
    @file = file
  end

  def load
    Config.load_and_set_settings(@file)

    # TODO

    CONFIG_CONST_NAME.constantize
  end
end
