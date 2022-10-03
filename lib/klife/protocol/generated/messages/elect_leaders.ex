defmodule Klife.Protocol.Messages.ElectLeaders do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 43

  def request_schema(0),
    do: [
      topic_partitions: {:array, [topic: :string, partitions: {:array, :int32}]},
      timeout_ms: :int32
    ]

  def request_schema(1),
    do: [
      election_type: :int8,
      topic_partitions: {:array, [topic: :string, partitions: {:array, :int32}]},
      timeout_ms: :int32
    ]

  def request_schema(2),
    do: [
      election_type: :int8,
      topic_partitions: {:array, [topic: :string, partitions: {:array, :int32}, tag_buffer: %{}]},
      timeout_ms: :int32,
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      replica_election_results:
        {:array,
         [
           topic: :string,
           partition_result:
             {:array, [partition_id: :int32, error_code: :int16, error_message: :string]}
         ]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      replica_election_results:
        {:array,
         [
           topic: :string,
           partition_result:
             {:array, [partition_id: :int32, error_code: :int16, error_message: :string]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      replica_election_results:
        {:array,
         [
           topic: :string,
           partition_result:
             {:array,
              [partition_id: :int32, error_code: :int16, error_message: :string, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end