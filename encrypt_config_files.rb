# frozen_string_literal: true

require_relative "lib/global"
Global.environment[:db] = false
Global.environment[:kv] = false

require_relative "base"

Configuration.all_config_decrypted_files.each do |file|
  result = Configuration.new(key: Global.environment[:config_key], file: file).write

  if result
    puts "Wrote encrypted yaml to #{ file }"
  else
    puts "No change in encrypted yaml in #{ file }"
  end
end
