defmodule Klife.Protocol.Messages.CreatePartitions do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 37

  def request_schema(0),
    do: [
      topics:
        {:array,
         [name: :string, count: :int32, assignments: {:array, [broker_ids: {:array, :int32}]}]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  def request_schema(1),
    do: [
      topics:
        {:array,
         [name: :string, count: :int32, assignments: {:array, [broker_ids: {:array, :int32}]}]},
      timeout_ms: :int32,
      validate_only: :boolean
    ]

  def request_schema(2),
    do: [
      topics:
        {:array,
         [
           name: :string,
           count: :int32,
           assignments: {:array, [broker_ids: {:array, :int32}, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def request_schema(3),
    do: [
      topics:
        {:array,
         [
           name: :string,
           count: :int32,
           assignments: {:array, [broker_ids: {:array, :int32}, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      timeout_ms: :int32,
      validate_only: :boolean,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      results: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      results: {:array, [name: :string, error_code: :int16, error_message: :string]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array, [name: :string, error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array, [name: :string, error_code: :int16, error_message: :string, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end