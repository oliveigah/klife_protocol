defmodule Klife.Protocol.Messages.AlterReplicaLogDirs do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 34

  def request_schema(0),
    do: [
      dirs:
        {:array, [path: :string, topics: {:array, [name: :string, partitions: {:array, :int32}]}]}
    ]

  def request_schema(1),
    do: [
      dirs:
        {:array, [path: :string, topics: {:array, [name: :string, partitions: {:array, :int32}]}]}
    ]

  def request_schema(2),
    do: [
      dirs:
        {:array,
         [
           path: :string,
           topics: {:array, [name: :string, partitions: {:array, :int32}, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           topic_name: :string,
           partitions: {:array, [partition_index: :int32, error_code: :int16]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           topic_name: :string,
           partitions: {:array, [partition_index: :int32, error_code: :int16]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      results:
        {:array,
         [
           topic_name: :string,
           partitions: {:array, [partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end