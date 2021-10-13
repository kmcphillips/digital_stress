# frozen_string_literal: true
module OpenaiData
  extend self

  def classifying?(server:, channel:)
    !!kv_store.read(classifying_key(server: server, channel: channel))
  end

  def classifying_on(server:, channel:)
    kv_store.write(classifying_key(server: server, channel: channel), "1")
    true
  end

  def classifying_off(server:, channel:)
    kv_store.delete(classifying_key(server: server, channel: channel))
    true
  end

  def classifications_file(server:, channel:)
    # TODO: this does nothing but return the default for now
    f = Global.config.openai.mandate_classifications_file
    raise "Cannnot find mandate classifications file key in config" unless f.present?
    f
  end

  private

  def kv_store
    Global.kv
  end

  def classifying_key(server:, channel:)
    "openai_classification:#{ server }:#{ channel }"
  end
end
