# frozen_string_literal: true

module AwsClient
  extend self

  def polly_say(text, voice: "Matthew")
    polly_client = Aws::Polly::Client.new

    response = polly_client.synthesize_speech(
      output_format: "mp3",
      text: text,
      voice_id: voice,
      engine: "neural"
    )

    file = Tempfile.create(["polly", ".mp3"], binmode: true)
    file.write(response.audio_stream.read)
    file.rewind

    file
  end
end
