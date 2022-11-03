# frozen_string_literal: true

# You can't tell rubyconfig to not export a `const_name` so just call it something dumb and never reference it
CONFIG_CONST_NAME = 'IgnoreMeGlobalConfiguration'

Config.setup do |config|
  config.const_name = CONFIG_CONST_NAME
  config.evaluate_erb_in_yaml = false
end

class Configuration
  attr_reader :key, :encrypted_file_path, :decrypted_file_path

  CYPHER = "aes-256-gcm"

  def initialize(key:, file:, key_file: "config/config_key")
    @key_file = key_file
    @file = file
    @key = load_key
    @encryptor = ActiveSupport::MessageEncryptor.new([@key].pack('H*'), cipher: CYPHER)
    load_file_paths
  end

  class << self
    def generate_key
      SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len(CYPHER))
    end

    def all_config_decrypted_files
      files = (Dir.glob("config/config.*.yml") + Dir.glob("config/config.yml")).map do |file|
        next if file == "config/config.example.yml"
        Global.root.join("#{file}.enc")
      end

      (files + [ Global.environment[:config] ]).compact.sort.uniq
    end

    def all_config_encrypted_files
      files = (Dir.glob("config/config.*.yml.enc") + Dir.glob("config/config.yml.enc")).map do |file|
        Global.root.join(file)
      end

      (files + [ Global.environment[:config] ]).compact.sort.uniq
    end
  end

  def read(force: false)
    if force || !File.exist?(decrypted_file_path)
      raise "Encrypted file #{ encrypted_file_path } does not exist" unless File.exist?(encrypted_file_path)

      encrypted_yaml = File.read(encrypted_file_path)
      decrypted_yaml = @encryptor.decrypt_and_verify(encrypted_yaml)
      yaml = YAML.safe_load(decrypted_yaml) # Unused but raises if invalid
      File.write(decrypted_file_path, decrypted_yaml)
    end

    Config.load_and_set_settings(decrypted_file_path)

    CONFIG_CONST_NAME.constantize
  end

  def write
    raise "Decrypted file `#{ decrypted_file_path }` did not exist to write" unless File.exist?(decrypted_file_path)

    decrypted_yaml = File.read(decrypted_file_path)
    yaml = YAML.safe_load(decrypted_yaml) # Unused but raises if invalid
    encrypted_yaml = @encryptor.encrypt_and_sign(decrypted_yaml)
    File.write(encrypted_file_path, encrypted_yaml)

    true
  end

  private

  def load_file_paths
    raise "Expected `#{ @file }` to end with `.enc`" unless @file.to_s.ends_with?('.enc')

    @encrypted_file_path = Global.root.join(@file.to_s)
    # raise "Config file `#{ @encrypted_file_path }` does not exist" unless File.exist?(@encrypted_file_path)

    @decrypted_file_path = Global.root.join(@file.to_s.gsub(/\.enc\Z/, ''))

    nil
  end

  def load_key
    @key ||= begin
      key_file_path = Global.root.join(@key_file)

      if key.present?
        key
      elsif File.exist?(key_file_path)
        key_file_contents = File.read(key_file_path).strip

        if key_file_contents.present?
          key_file_contents
        else
          raise "Config key in `#{ @key_file }` file is blank."
        end
      else
        raise "No config key present. Provide `DUCK_CONFIG_KEY` env var or create a `#{ @key_file }` file."
      end
    end
  end
end
