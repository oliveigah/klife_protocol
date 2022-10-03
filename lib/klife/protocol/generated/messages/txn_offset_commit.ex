defmodule Klife.Protocol.Messages.TxnOffsetCommit do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 28

  def request_schema(0),
    do: [
      transactional_id: :string,
      group_id: :string,
      producer_id: :int64,
      producer_epoch: :int16,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  def request_schema(1),
    do: [
      transactional_id: :string,
      group_id: :string,
      producer_id: :int64,
      producer_epoch: :int16,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [partition_index: :int32, committed_offset: :int64, committed_metadata: :string]}
         ]}
    ]

  def request_schema(2),
    do: [
      transactional_id: :string,
      group_id: :string,
      producer_id: :int64,
      producer_epoch: :int16,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                committed_offset: :int64,
                committed_leader_epoch: :int32,
                committed_metadata: :string
              ]}
         ]}
    ]

  def request_schema(3),
    do: [
      transactional_id: :string,
      group_id: :string,
      producer_id: :int64,
      producer_epoch: :int16,
      generation_id: :int32,
      member_id: :string,
      group_instance_id: :string,
      topics:
        {:array,
         [
           name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                committed_offset: :int64,
                committed_leader_epoch: :int32,
                committed_metadata: :string,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [name: :string, partitions: {:array, [partition_index: :int32, error_code: :int16]}]}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           name: :string,
           partitions: {:array, [partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end