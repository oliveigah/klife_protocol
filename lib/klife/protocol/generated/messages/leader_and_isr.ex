defmodule Klife.Protocol.Messages.LeaderAndIsr do
  alias Klife.Protocol.Deserializer
  alias Klife.Protocol.Serializer
  alias Klife.Protocol.Header

  def get_api_key(), do: 4

  def request_schema(0),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      ungrouped_partition_states:
        {:array,
         [
           topic_name: :string,
           partition_index: :int32,
           controller_epoch: :int32,
           leader: :int32,
           leader_epoch: :int32,
           isr: {:array, :int32},
           partition_epoch: :int32,
           replicas: {:array, :int32}
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
    ]

  def request_schema(1),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      ungrouped_partition_states:
        {:array,
         [
           topic_name: :string,
           partition_index: :int32,
           controller_epoch: :int32,
           leader: :int32,
           leader_epoch: :int32,
           isr: {:array, :int32},
           partition_epoch: :int32,
           replicas: {:array, :int32},
           is_new: :boolean
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
    ]

  def request_schema(2),
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
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                replicas: {:array, :int32},
                is_new: :boolean
              ]}
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
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
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                replicas: {:array, :int32},
                adding_replicas: {:array, :int32},
                removing_replicas: {:array, :int32},
                is_new: :boolean
              ]}
         ]},
      live_leaders: {:array, [broker_id: :int32, host_name: :string, port: :int32]}
    ]

  def request_schema(4),
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
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                replicas: {:array, :int32},
                adding_replicas: {:array, :int32},
                removing_replicas: {:array, :int32},
                is_new: :boolean,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      live_leaders:
        {:array, [broker_id: :int32, host_name: :string, port: :int32, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(5),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      type: :int8,
      topic_states:
        {:array,
         [
           topic_name: :string,
           topic_id: :uuid,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                replicas: {:array, :int32},
                adding_replicas: {:array, :int32},
                removing_replicas: {:array, :int32},
                is_new: :boolean,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      live_leaders:
        {:array, [broker_id: :int32, host_name: :string, port: :int32, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def request_schema(6),
    do: [
      controller_id: :int32,
      controller_epoch: :int32,
      broker_epoch: :int64,
      type: :int8,
      topic_states:
        {:array,
         [
           topic_name: :string,
           topic_id: :uuid,
           partition_states:
             {:array,
              [
                partition_index: :int32,
                controller_epoch: :int32,
                leader: :int32,
                leader_epoch: :int32,
                isr: {:array, :int32},
                partition_epoch: :int32,
                replicas: {:array, :int32},
                adding_replicas: {:array, :int32},
                removing_replicas: {:array, :int32},
                is_new: :boolean,
                leader_recovery_state: :int8,
                tag_buffer: %{}
              ]},
           tag_buffer: %{}
         ]},
      live_leaders:
        {:array, [broker_id: :int32, host_name: :string, port: :int32, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(0),
    do: [
      error_code: :int16,
      partition_errors:
        {:array, [topic_name: :string, partition_index: :int32, error_code: :int16]}
    ]

  def response_schema(1), do: [error_code: :int16]
  def response_schema(2), do: [error_code: :int16]
  def response_schema(3), do: [error_code: :int16]

  def response_schema(4),
    do: [
      error_code: :int16,
      partition_errors:
        {:array,
         [topic_name: :string, partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
      tag_buffer: %{}
    ]

  def response_schema(5),
    do: [
      error_code: :int16,
      topics:
        {:array,
         [
           topic_id: :uuid,
           partition_errors:
             {:array, [partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]

  def response_schema(6),
    do: [
      error_code: :int16,
      topics:
        {:array,
         [
           topic_id: :uuid,
           partition_errors:
             {:array, [partition_index: :int32, error_code: :int16, tag_buffer: %{}]},
           tag_buffer: %{}
         ]},
      tag_buffer: %{}
    ]
end