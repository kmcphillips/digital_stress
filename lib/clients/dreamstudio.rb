# frozen_string_literal: true
# This uses protobuf and grpc generated code. Built with 'grpc-tools' gem:
# grpc_tools_ruby_protoc -I ./protobuf --ruby_out=./lib --grpc_out=./lib protobuf/generation.proto
module Dreamstudio
  extend self

  def generate_images(prompt:)
    request = build_request(prompt: prompt)
    stub = generation_service_stub
    answers = []

    Global.logger.info("[Dreamstudio] request #{ request } prompt:\n#{ prompt }")

    stub.generate(request).each do |answer|
      if answer.artifacts.any?
        answers << answer
      else
        # keepalive answer with no artifacts
      end
    end

    image_artifacts = []

    answers.each do |answer|
      answer.artifacts.each do |artifact|
        if artifact.type == :ARTIFACT_IMAGE
          image_artifacts << artifact
        else
          Global.logger.warn("[Dreamstudio] unexpected artifact #{ artifact }")

          if artifact.type == :ARTIFACT_TEXT
            raise "Generation artifact finished with reason '#{ artifact.finish_reason }'"
          end
        end
      end
    end

    Global.logger.info("[Dreamstudio] received #{ answers.size } answers and #{ image_artifacts.size } image artifacts")

    image_artifacts
  end

  def generate_image(prompt:)
    generate_images(prompt: prompt).first
  end

  private

  def api_key
    Global.config.dreamstudio.key
  end

  def generation_service_stub
    channel_credentials = GRPC::Core::ChannelCredentials.new()
    call_credentials = GRPC::Core::CallCredentials.new(->(_) { { authorization: "Bearer #{ api_key }" } })
    Gooseai::GenerationService::Stub.new("grpc.stability.ai:443", channel_credentials.compose(call_credentials))
  end

  def build_request(prompt:)
    Gooseai::Request.new(
      requested_type: Gooseai::ArtifactType::ARTIFACT_IMAGE,
      engine_id: "stable-diffusion-v1-5",
      request_id: SecureRandom.uuid,
      classifier: Gooseai::ClassifierParameters.new(),
      prompt: [
        Gooseai::Prompt.new(
          text: prompt
        )
      ],
      image: Gooseai::ImageParameters.new(
        height: 512,
        width: 512,
        steps: 50,
        samples: 1,
        seed: [ rand(4294967295) ],
        transform: Gooseai::TransformType.new(diffusion: Gooseai::DiffusionSampler::SAMPLER_K_LMS),
        parameters: [
          Gooseai::StepParameter.new(
            scaled_step: 0,
            sampler: Gooseai::SamplerParameters.new(cfg_scale: 7.0)
          ),
        ],
      )
    )
  end
end
