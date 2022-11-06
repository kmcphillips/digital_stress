# frozen_string_literal: true

require_relative "lib/global"
Global.environment[:db] = false
Global.environment[:kv] = false

require_relative "base"

Configuration.all_config_encrypted_files.each do |file|
  Configuration.new(key: Global.environment[:config_key], file: file).read(force: true)

  puts "Wrote yaml from #{ file }"
end
