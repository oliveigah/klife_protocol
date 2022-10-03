defmodule Klife.Protocol.Messages.FindCoordinator do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 10

  def request_schema(0), do: [key: :string]
  def request_schema(1), do: [key_type: :int8]
  def request_schema(2), do: [key_type: :int8]
  def request_schema(3), do: [key: :string, key_type: :int8, tag_buffer: %{}]

  def request_schema(4),
    do: [key_type: :int8, coordinator_keys: {:array, :string}, tag_buffer: %{}]

  def response_schema(0), do: [error_code: :int16, node_id: :int32, host: :string, port: :int32]
  def response_schema(1), do: [throttle_time_ms: :int32, error_message: :string]
  def response_schema(2), do: [throttle_time_ms: :int32]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      error_message: :string,
      node_id: :int32,
      host: :string,
      port: :int32,
      tag_buffer: %{}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      coordinators:
        {:array,
         [
           key: :string,
           node_id: :int32,
           host: :string,
           port: :int32,
           error_code: :int16,
           error_message: :string,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end