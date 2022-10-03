defmodule Klife.Protocol.Messages.IncrementalAlterConfigs do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 44

  def request_schema(0),
    do: [
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           configs: {:array, [name: :string, config_operation: :int8, value: :string]}
         ]},
      validate_only: :boolean
    ]

  def request_schema(1),
    do: [
      resources:
        {:array,
         [
           resource_type: :int8,
           resource_name: :string,
           configs:
             {:array, [name: :string, config_operation: :int8, value: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      responses:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      responses:
        {:array,
         [
           error_code: :int16,
           error_message: :string,
           resource_type: :int8,
           resource_name: :string,
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end