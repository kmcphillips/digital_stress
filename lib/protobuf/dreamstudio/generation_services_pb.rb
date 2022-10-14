# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: dreamstudio/generation.proto for package 'gooseai'

require 'grpc'
# require 'dreamstudio/generation_pb'

module Gooseai
  module GenerationService
    #
    # gRPC services
    #
    class Service

      include ::GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'gooseai.GenerationService'

      rpc :Generate, ::Gooseai::Request, stream(::Gooseai::Answer)
      rpc :ChainGenerate, ::Gooseai::ChainRequest, stream(::Gooseai::Answer)
    end

    Stub = Service.rpc_stub_class
  end
end
