defmodule Klife.Protocol.Messages.BrokerRegistration do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 62

  def request_schema(0),
    do: [
      broker_id: :int32,
      cluster_id: :string,
      incarnation_id: :uuid,
      listeners:
        {:array,
         [name: :string, host: :string, port: :uint16, security_protocol: :int16, tag_buffer: %{}]},
      features:
        {:array,
         [
           name: :string,
           min_supported_version: :int16,
           max_supported_version: :int16,
           tag_buffer: %{}
         ]},
      rack: :string,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [throttle_time_ms: :int32, error_code: :int16, broker_epoch: :int64, tag_buffer: %{}]
end