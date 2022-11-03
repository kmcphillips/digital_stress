# frozen_string_literal: true

require_relative "lib/global"
Global.environment[:db_file] = false
Global.environment[:kv] = false

require_relative "base"

Configuration.all_config_decrypted_files.each do |file|
  Configuration.new(key: Global.environment[:config_key], file: file).write

  puts "Wrote encrypted yaml to #{ file }"
end
