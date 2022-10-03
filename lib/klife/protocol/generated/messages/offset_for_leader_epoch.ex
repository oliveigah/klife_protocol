defmodule Klife.Protocol.Messages.OffsetForLeaderEpoch do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 23

  def request_schema(0),
    do: [
      topics:
        {:array,
         [topic: :string, partitions: {:array, [partition: :int32, leader_epoch: :int32]}]}
    ]

  def request_schema(1),
    do: [
      topics:
        {:array,
         [topic: :string, partitions: {:array, [partition: :int32, leader_epoch: :int32]}]}
    ]

  def request_schema(2),
    do: [
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array, [partition: :int32, current_leader_epoch: :int32, leader_epoch: :int32]}
         ]}
    ]

  def request_schema(3),
    do: [
      replica_id: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array, [partition: :int32, current_leader_epoch: :int32, leader_epoch: :int32]}
         ]}
    ]

  def request_schema(4),
    do: [
      replica_id: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [
                partition: :int32,
                current_leader_epoch: :int32,
                leader_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      topics:
        {:array,
         [
           topic: :string,
           partitions: {:array, [error_code: :int16, partition: :int32, end_offset: :int64]}
         ]}
    ]

  def response_schema(1),
    do: [
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [error_code: :int16, partition: :int32, leader_epoch: :int32, end_offset: :int64]}
         ]}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [error_code: :int16, partition: :int32, leader_epoch: :int32, end_offset: :int64]}
         ]}
    ]

  def response_schema(3),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [error_code: :int16, partition: :int32, leader_epoch: :int32, end_offset: :int64]}
         ]}
    ]

  def response_schema(4),
    do: [
      throttle_time_ms: :int32,
      topics:
        {:array,
         [
           topic: :string,
           partitions:
             {:array,
              [
                error_code: :int16,
                partition: :int32,
                leader_epoch: :int32,
                end_offset: :int64,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end