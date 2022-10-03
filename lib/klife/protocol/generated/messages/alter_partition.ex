defmodule Klife.Protocol.Messages.AlterPartition do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 56

  def request_schema(0),
    do: [
      broker_id: :int32,
      broker_epoch: :int64,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                new_isr: {:array, :int32},
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def request_schema(1),
    do: [
      broker_id: :int32,
      broker_epoch: :int64,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                new_isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def request_schema(2),
    do: [
      broker_id: :int32,
      broker_epoch: :int64,
      topics:
        {:array,
         [
           topic_id: :uuid,
           partitions:
             {:array,
              [
                partition_index: :int32,
                leader_epoch: :int32,
                new_isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(1),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:array,
         [
           topic_name: :string,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(2),
    do: [
      throttle_time_ms: :int32,
      error_code: :int16,
      topics:
        {:array,
         [
           topic_id: :uuid,
           partitions:
             {:array,
              [
                partition_index: :int32,
                error_code: :int16,
                leader_id: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                leader_recovery_state: :int8,
                partition_epoch: :int32,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end