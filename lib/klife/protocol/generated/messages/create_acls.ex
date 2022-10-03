defmodule Klife.Protocol.Messages.CreateAcls do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 30

  def request_schema(0),
    do: [
      creations:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           principal: :string,
           host: :string,
           operation: :int8,
           permission_type: :int8
         ]}
    ]

  def request_schema(1),
    do: [
      creations:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           resource_pattern_type: :int8,
           principal: :string,
           host: :string,
           operation: :int8,
           permission_type: :int8
         ]}
    ]

  def request_schema(2),
    do: [
      creations:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           resource_pattern_type: :int8,
           principal: :string,
           host: :string,
           operation: :int8,
           permission_type: :int8,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def request_schema(3),
    do: [
      creations:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           resource_pattern_type: :int8,
           principal: :string,
           host: :string,
           operation: :int8,
           permission_type: :int8,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      results: {:array, [error_code: :int16, error_message: :string]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      results: {:array, [error_code: :int16, error_message: :string]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      results: {:array, [error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      results: {:array, [error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end