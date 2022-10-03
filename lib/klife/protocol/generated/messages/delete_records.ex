defmodule Klife.Protocol.Messages.DeleteRecords do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 21

  def request_schema(0),
    do: [
      topics:
        {:array, [name: :string, partitions: {:array, [partition_index: :int32, offset: :int64]}]},
      timeout_ms: :int32
    ]

  def request_schema(1),
    do: [
      topics:
        {:array, [name: :string, partitions: {:array, [partition_index: :int32, offset: :int64]}]},
      timeout_ms: :int32
    ]

  def request_schema(2),
    do: [
      topics:
        {:array,
         [
           name: :string,
           partitions: {:array, [partition_index: :int32, offset: :int64, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      timeout_ms: :int32,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array, [partition_index: :int32, low_watermark: :int64, error_code: :int16]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array, [partition_index: :int32, low_watermark: :int64, error_code: :int16]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                low_watermark: :int64,
                error_code: :int16,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end