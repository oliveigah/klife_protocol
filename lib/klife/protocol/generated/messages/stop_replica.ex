defmodule Klife.Protocol.Messages.StopReplica do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 5

  def request_schema(0),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      delete_partitions: :boolean,
      ungrouped_partitions: {:array, [topic_name: :string, partition_index: :int32]}
    ]

  def request_schema(1),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}]}
    ]

  def request_schema(2),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      delete_partitions: :boolean,
      topics: {:array, [name: :string, partition_indexes: {:array, :int32}, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(3),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      topic_states:
        {:array,
         [
           topic_name: :string,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                delete_partition: :boolean,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      error_code: :int16,
      partition_errors:
        {:array, [topic_name: :string, partition_index: :int32, error_code: :int16]}
    ]

  def response_schema(1),
    do: [
      error_code: :int16,
      partition_errors:
        {:array, [topic_name: :string, partition_index: :int32, error_code: :int16]}
    ]

  def response_schema(2),
    do: [
      error_code: :int16,
      partition_errors:
        {:array,
         [topic_name: :string, partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(3),
    do: [
      error_code: :int16,
      partition_errors:
        {:array,
         [topic_name: :string, partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]
end